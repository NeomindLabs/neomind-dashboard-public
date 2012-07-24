# encoding: utf-8

require './stoplight_color_numbers'
require './config_loader'

class CiBuildStatusUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(ci_build_status_reader)
		@ci_build_status_reader = ci_build_status_reader
	end
	
	BUILD_STATUS_COLORS = {
		build_failed: :red,
		build_ok: :green,
		build_in_progress: :yellow,
		build_in_queue: :yellow,
		not_built: :yellow,
		builder_error: :yellow,
		hook_error: :yellow,
	}
	
	def update(updater)
		project_name_stream_names = CONFIG["stream names"]["statuses for CI project names"]
		
		project_statuses = @ci_build_status_reader.get_statuses
		project_statuses.each do |status|
			build_status = status[:build_status]
			begin
				color = BUILD_STATUS_COLORS[build_status]
			rescue KeyError
				raise "unknown build status “#{build_status}”"
			end
			number = STOPLIGHT_COLOR_NUMBERS[color]
			
			project_name = status[:name]
			begin
				stream_name = project_name_stream_names.fetch(project_name)
			rescue KeyError
				raise "CI project “#{project_name}” has no corresponding stream"
			end
			
			updater.push_number(stream_name, number)
		end
	end
end
