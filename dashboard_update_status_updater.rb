# encoding: utf-8

require './config_loader'
require './stoplight_color_numbers'
require './update_status_html_generator'

class SinglePartDashboardUpdateStatusUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(updater)
		@updater = updater
	end
	
	def update(status)
		update_spotlight(status)
		update_text(status)
	end
	
	private
	
	def update_spotlight(status)
		status_stream_name = CONFIG["stream names"]["updater script"]["status spotlight"]
		status_colors = {:success => :green, :in_progress => :yellow, :error => :red}
		number = STOPLIGHT_COLOR_NUMBERS[status_colors[status]]
		@updater.push_number(status_stream_name, number)
	end
	
	def update_text(status)
		status_stream_name = CONFIG["stream names"]["updater script"]["status text"]
		html = WholeDashboardUpdateStatusHtmlGenerator.html_explanation_of_status(status)
		@updater.push_html(status_stream_name, html)
	end
end


class DashboardPartUpdateStatusUpdaterFactory
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(updater)
		@updater = updater
	end
	
	def new_updater_for_part(part_id)
		DashboardPartUpdateStatusUpdater.new(@updater, part_id)
	end
end


class DashboardPartUpdateStatusUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(updater, part_id)
		@updater = updater
		@part_id = part_id
		
		@status_text_stream_name = stream_name_for_part(part_id)
	end
	
	def update(status)
		html = SinglePartUpdateStatusHtmlGenerator.html_explanation_of_status(status)
		@updater.push_html(@status_text_stream_name, html)
	end
	
	private
	
	def stream_name_for_part(part_id)
		part_id_stream_names = CONFIG["stream names"]["updater script"]["statuses for part IDs"]
		
		return begin
			part_id_string = part_id.to_s
			part_id_stream_names.fetch(part_id_string)
		rescue KeyError
			raise "updater part “#{part_id}” has no corresponding stream"
		end
	end
end
