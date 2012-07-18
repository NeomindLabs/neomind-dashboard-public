# encoding: utf-8

require './config_loader'
require './dashboard_update_status_updater'

require './leftronic/ruby/leftronic'

class DashboardUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
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
		access_key = CONFIG["dashboard access key"]
		@updater = Leftronic.new access_key
	end
end