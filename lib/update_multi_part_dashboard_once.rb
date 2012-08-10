# encoding: utf-8

require_relative 'multi_part_dashboard_updater'
require_relative 'ci_build_status_updater'
require_relative 'bigtuna_ci_project_status_reader'
require_relative 'hours_logged_updater'
require_relative 'freckle_hours_logged_reader'
require_relative 'exception_printing'

updater = MultiPartDashboardUpdater.new

threads = {
	:update_build_status => ExceptionPrinting::ThreadBuilder.new_thread do
		updater.update_part(:build_status) do |updater|
			build_status_updater = CiBuildStatusUpdater.new(BigtunaCiProjectStatusReader.new)
			build_status_updater.update(updater)
		end
	end,

	:update_hours => ExceptionPrinting::ThreadBuilder.new_thread do
		updater.update_part(:hours) do |updater|
			hours_updater = HoursLoggedUpdater.new(FreckleHoursLoggedReader.new)
			hours_updater.update(updater)
		end
	end,
}

threads.each_value(&:join)
