# encoding: utf-8

require './bigtuna-ci-project-statuses'
require './freckle-hours-worked'
require './config-loader'

require './leftronic/ruby/leftronic'
require 'date'

CONFIG = ConfigLoader.new

STOPLIGHT_COLOR_NUMBERS = {
	green: 0,
	yellow: 50,
	red: 100,
}

class CiBuildStatusUpdater
	def initialize(ci_build_status_reader)
		@ci_build_status_reader = ci_build_status_reader
	end
	
	def update(updater)
		build_status_colors = {
			build_failed: :red,
			build_ok: :green,
			build_in_progress: :yellow,
			build_in_queue: :yellow,
			not_built: :yellow,
			builder_error: :yellow,
			hook_error: :yellow,
		}
		
		project_name_stream_names = CONFIG["Leftronic dashboard"]["stream names"]["statuses for CI project names"]
		
		project_statuses = @ci_build_status_reader.get_statuses
		project_statuses.each do |status|
			build_status = status[:build_status]
			rating = build_status_colors[build_status]
			raise "unknown build status “#{build_status}”" if rating.nil?
			number = STOPLIGHT_COLOR_NUMBERS[rating]
			
			project_name = status[:name]
			stream_name = project_name_stream_names[project_name]
			raise "CI project “#{project_name}” has no corresponding stream" if stream_name.nil?
			
			updater.push_number(stream_name, number)
		end
	end
end

class HoursLoggedUpdater
	def initialize(hours_logged_reader)
		@hours_logged_reader = hours_logged_reader
	end
	
	def update(updater)
		hours_stream_name = CONFIG["Leftronic dashboard"]["stream names"]["Freckle"]
		
		dates = (0..7).map do |days_ago|
			Date.today.prev_day(days_ago)
		end
		data_points = dates.map do |date|
			{
				number: begin
					hours_logged = @hours_logged_reader.get_total_hours_logged_on(date)
				end,
				timestamp: begin
					normalized_date = date.to_time.utc
					unix_timestamp = normalized_date.strftime('%s').to_i
				end,
				suffix: " hours",
			}
		end
		data_points.reverse!
		
		updater.clear(hours_stream_name)
		updater.push_number(hours_stream_name, data_points)
	end
end

class DashboardUpdateStatusUpdater
	def initialize(updater)
		@updater = updater
	end
	
	def update(status)
		update_spotlight(status)
		update_text(status)
	end
	
	private
	
	def update_spotlight(status)
		status_stream_name = CONFIG["Leftronic dashboard"]["stream names"]["updater script"]["status spotlight"]
		status_colors = {:success => :green, :in_progress => :yellow, :error => :red}
		number = STOPLIGHT_COLOR_NUMBERS[status_colors[status]]
		@updater.push_number(status_stream_name, number)
	end
	
	def update_text(status)
		status_stream_name = CONFIG["Leftronic dashboard"]["stream names"]["updater script"]["status text"]
		html = UpdateStatusHtmlGenerator.html_explanation_of_status(status)
		@updater.push_html(status_stream_name, html)
	end
end

module UpdateStatusHtmlGenerator
	def self.html_explanation_of_status(status)
		case status
		when :success
			html_of_time_with_header("Dashboard last "+camouflaged_link_to_script_code("updated"))
		when :in_progress
			"Updating dashboard (#{short_term_time_string})…"
		when :error
			html_of_time_with_header("Dashboard "+camouflaged_link_to_script_code("update")+" failed")
		end
	end
	
	private
	
	def self.camouflaged_link_to_script_code(link_text)
		script_code_url = CONFIG["updater script"]["code URL"]
		surrounding_text_color = '#CCC'
		
		'<a href="'+script_code_url+'" style="color: '+surrounding_text_color+'">'+link_text+'</a>'
	end
	
	def self.html_of_time_with_header(header_body)
		header = "<h2>#{header_body}:</h2>"
		section_separator = "\n\n"
		time_html = "<div>#{medium_term_time_string}</div>"
		
		return header + section_separator + time_html
	end
	
	def self.medium_term_time_string
		# time format: "Wed 2:34 PM"
		Time.now.strftime '%a %-l:%M %p'
	end
	
	def self.short_term_time_string
		# time format: "2:34 PM"
		Time.now.strftime '%-l:%M %p'
	end
end

class DashboardUpdater
	def initialize
		initialize_updater
	end
	
	def update
		status_updater = DashboardUpdateStatusUpdater.new @updater
		begin
			status_updater.update(:in_progress)
			
			yield @updater
			
			status_updater.update(:success)
		rescue Exception
			status_updater.update(:error)
			raise
		end
	end
	
	private
	
	def initialize_updater
		access_key = CONFIG["Leftronic dashboard"]["dashboard access key"]
		@updater = Leftronic.new access_key
	end
end

DashboardUpdater.new.update do |updater|
	build_status_updater = CiBuildStatusUpdater.new(BigTunaCiProjectStatusReader.new)
	build_status_updater.update(updater)
	
	hours_updater = HoursLoggedUpdater.new(FreckleHoursLoggedReader.new)
	hours_updater.update(updater)
end
