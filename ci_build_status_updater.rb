# encoding: utf-8

require './stoplight_color_numbers'
require './config_loader'

class CiBuildStatusUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(ci_build_status_reader)
		@ci_build_status_reader = ci_build_status_reader
	end
	
	def update(updater)
		project_statuses = @ci_build_status_reader.get_statuses
		project_statuses.each do |status|
			build_status = status[:build_status]
			number = number_to_stream_for_status(build_status)
			
			project_name = status[:name]
			stream_name = stream_name_for_project(project_name)
			
			updater.push_number(stream_name, number)
		end
	end
	
	private
	
	BUILD_STATUS_COLORS = {
		build_failed: :red,
		build_ok: :green,
		build_in_progress: :yellow,
		build_in_queue: :yellow,
		not_built: :yellow,
		builder_error: :yellow,
		hook_error: :yellow,
	}
	
	def number_to_stream_for_status(build_status)
		color = begin
			BUILD_STATUS_COLORS.fetch(build_status)
		rescue KeyError
			raise "unknown build status “#{build_status}”"
		end
		return STOPLIGHT_COLOR_NUMBERS[color]
	end
	
	def stream_name_for_project(project_name)
		project_name_stream_names = CONFIG["stream names"]["statuses for CI project names"]
		
		return begin
			project_name_stream_names.fetch(project_name)
		rescue KeyError
			raise "CI project “#{project_name}” has no corresponding stream"
		end
	end
end
