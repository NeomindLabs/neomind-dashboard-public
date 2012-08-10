# encoding: utf-8

require_relative 'single_part_dashboard_updater'
require_relative 'ci_build_status_updater'
require_relative 'bigtuna_ci_project_status_reader'
require_relative 'hours_logged_updater'
require_relative 'freckle_hours_logged_reader'

SinglePartDashboardUpdater.new.update do |updater|
	build_status_updater = CiBuildStatusUpdater.new(BigtunaCiProjectStatusReader.new)
	build_status_updater.update(updater)
	
	hours_updater = HoursLoggedUpdater.new(FreckleHoursLoggedReader.new)
	hours_updater.update(updater)
end
