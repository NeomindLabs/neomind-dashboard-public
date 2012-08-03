# encoding: utf-8

require_relative 'config_loader'
require_relative 'single_part_update_status_html_generator'

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
