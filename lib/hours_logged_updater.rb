# encoding: utf-8

require_relative 'config_loader'

require 'date'

class HoursLoggedUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(hours_logged_reader)
		@hours_logged_reader = hours_logged_reader
	end
	
	def update(updater)
		hours_stream_name = CONFIG["stream names"]["daily logged hours"]
		
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
