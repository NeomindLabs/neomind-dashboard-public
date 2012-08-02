# encoding: utf-8

require './config_loader'
require './dashboard_part_update_status_updater'

class DashboardPartUpdateStatusUpdaterFactory
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize(updater)
		@updater = updater
	end
	
	def new_updater_for_part(part_id)
		DashboardPartUpdateStatusUpdater.new(@updater, part_id)
	end
end
