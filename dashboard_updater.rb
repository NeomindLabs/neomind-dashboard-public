# encoding: utf-8

require './config_loader'
require './dashboard_update_status_updater'

require './leftronic/ruby/leftronic'

class DashboardUpdater
	CONFIG = ConfigLoader.new.config_for("Leftronic dashboard")
	
	def initialize
		initialize_updater
	end
	
	private
	
	def update_with_status_updater(status_updater)
		
		begin
			status_updater.update(:in_progress)
			
			yield @updater
			
			status_updater.update(:success)
		rescue Exception
			status_updater.update(:error)
			raise
		end
	end
	
	def initialize_updater
		access_key = CONFIG["dashboard access key"]
		@updater = Leftronic.new(access_key)
	end
end


class SinglePartDashboardUpdater < DashboardUpdater
	def update(&block)
		status_updater = SinglePartDashboardUpdateStatusUpdater.new(@updater)
		update_with_status_updater(status_updater, &block)
	end
end


class MultiPartDashboardUpdater < DashboardUpdater
	def initialize
		super
		initialize_status_updater_factory(@updater)
	end
	
	def update_part(part_id, &block)
		part_status_updater = @status_updater_factory.new_updater_for_part(part_id)
		update_with_status_updater(part_status_updater, &block)
	end
	
	private
	
	def initialize_status_updater_factory(updater)
		@status_updater_factory = DashboardPartUpdateStatusUpdaterFactory.new(updater)
	end
end
