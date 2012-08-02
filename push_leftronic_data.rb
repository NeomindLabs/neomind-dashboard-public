# encoding: utf-8

require './dashboard_updater'
require './ci_build_status_updater'
require './bigtuna_ci_project_status_reader'
require './hours_logged_updater'
require './freckle_hours_logged_reader'

try_updating_multipart = true

unless try_updating_multipart
	SinglePartDashboardUpdater.new.update do |updater|
		build_status_updater = CiBuildStatusUpdater.new(BigtunaCiProjectStatusReader.new)
		build_status_updater.update(updater)
		
		hours_updater = HoursLoggedUpdater.new(FreckleHoursLoggedReader.new)
		hours_updater.update(updater)
	end
end

if try_updating_multipart
	updater = MultiPartDashboardUpdater.new

	updater.update_part(:build_status) do |updater|
		# raise "test error"
		build_status_updater = CiBuildStatusUpdater.new(BigtunaCiProjectStatusReader.new)
		build_status_updater.update(updater)
	end

	updater.update_part(:hours) do |updater|
		hours_updater = HoursLoggedUpdater.new(FreckleHoursLoggedReader.new)
		hours_updater.update(updater)
	end
end
