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
		html = UpdateStatusHtmlGenerator.html_explanation_of_status(status)
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
	
	private
	
	# def …
end


class DashboardPartUpdateStatusUpdater
	def initialize(updater, part_id)
		@updater = updater
		@part_id = part_id
		# probably also pass in shared state and later access it thread-safely
	end
	
	def update(status)
		# …
	end
	
	private
	
	# def …
end
