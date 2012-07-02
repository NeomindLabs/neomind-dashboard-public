#!ruby
# encoding: utf-8

require './bigtuna-ci-project-statuses'
require './freckle-hours-worked'

require './leftronic/ruby/leftronic'
require 'date'

def update_build_statuses(updater)
	build_status_ratings = {
		failed: 100,
		in_progress: 50,
		in_queue: 50,
		ok: 0,
	}
	project_name_stream_names = {
		"Project A" => 'project_a_ci_status',
		"Project B" => 'project_b_ci_status',
		"Project C" => 'project_c_ci_status',
		"Project D" => 'project_d_ci_status',
		"Project E" => 'project_e_ci_status',
		"Project G" => 'project_g_ci_status',
		"Project F" => 'project_f_ci_status',
	}
	
	project_statuses = get_project_statuses
	project_statuses.each do |status|
		rating = build_status_ratings[ status[:build_status] ]
		raise "unknown build status" if rating.nil?
		project_name = status[:name]
		stream_name = project_name_stream_names[project_name]
		raise "CI project “#{project_name}” has no corresponding stream" if stream_name.nil?
		updater.push_number stream_name, rating
	end
end

def update_freckle_hours(updater)
	freckle_stream_name = 'freckle_daily_hours'
	
	data_points = (0..7).map do |days_ago|
		date = Date.today.prev_day(days_ago)
		hours_logged = get_total_hours_logged_on(date)
		
		normalized_date = date.to_time.utc
		unix_timestamp = normalized_date.strftime('%s').to_i
		data_point = {number: hours_logged, timestamp: unix_timestamp, suffix: " hours"}
		data_point
	end.reverse
	
	updater.clear(freckle_stream_name)
	updater.push_number(freckle_stream_name, data_points)
end

class LeftronicUpdateStatusUpdater
	def update(updater, status)
		update_spotlight(updater, status)
		update_text(updater, status)
	end
	
	private
	
	def update_spotlight(updater, status)
		status_stream_name = 'updater_script_status_spotlight'
		status_ratings = {:success => 0, :in_progress => 50, :error => 100}
		updater.push_number status_stream_name, status_ratings[status]
	end

	def update_text(updater, status)
		status_stream_name = 'updater_script_status_text'
		
		html = begin
			case status
			when :success
				html_of_time_with_header("Dashboard last "+invisible_link_to_script_code("updated"))
			when :in_progress
				# time format: "2:34 PM"
				short_term_time_string = Time.now.strftime '%-l:%M %p'
				"Updating dashboard (#{short_term_time_string})…"
			when :error
				html_of_time_with_header("Dashboard "+invisible_link_to_script_code("update")+" failed")
			end
		end
		
		updater.push_html status_stream_name, html
	end
	
	def invisible_link_to_script_code(link_text)
		script_code_url = 'https://github.com/NeomindLabs/neomind-dashboard'
		surrounding_text_color = '#CCC'
		'<a href="'+script_code_url+'" style="color: '+surrounding_text_color+'">'+link_text+'</a>'
	end

	def html_of_time_with_header(header_body)
		# time format: "Wed 2:34 PM"
		medium_term_time_string = Time.now.strftime '%a %-l:%M %p'
		
		header = "<h2>#{header_body}:</h2>"
		section_separator = "\n\n"
		time_html = "<div>#{medium_term_time_string}</div>"
		
		return header + section_separator + time_html
	end
end

def update_dashboard
	access_key = 'redacted'
	updater = Leftronic.new access_key
	status_updater = LeftronicUpdateStatusUpdater.new
	begin
		status_updater.update(updater, :in_progress)
		yield updater
		status_updater.update(updater, :success)
	rescue Exception
		status_updater.update(updater, :error)
		raise
	end
end

update_dashboard do |updater|
	update_build_statuses(updater)
	update_freckle_hours(updater)
end
