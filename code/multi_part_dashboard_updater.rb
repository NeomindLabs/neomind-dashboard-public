# encoding: utf-8

require_relative 'dashboard_updater'
require_relative 'dashboard_part_update_status_updater_factory'

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
