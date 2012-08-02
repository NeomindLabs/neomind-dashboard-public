# encoding: utf-8

require './dashboard_updater'
require './single_part_dashboard_update_status_updater'

class SinglePartDashboardUpdater < DashboardUpdater
	def update(&block)
		status_updater = SinglePartDashboardUpdateStatusUpdater.new(@updater)
		update_with_status_updater(status_updater, &block)
	end
end
