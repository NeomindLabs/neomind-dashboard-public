# encoding: utf-8

require_relative 'multi_part_dashboard_updater'
require_relative 'ci_build_status_updater'
require_relative 'bigtuna_ci_project_status_reader'
require_relative 'hours_logged_updater'
require_relative 'freckle_hours_logged_reader'
require_relative 'expect_interrupt'

require 'rufus/scheduler'

updater = MultiPartDashboardUpdater.new
scheduler = Rufus::Scheduler.start_new

# scheduler.every '5m' do
scheduler.every '20s' do
	updater.update_part(:build_status) do |updater|
		
		sleep 5
		# build_status_updater = CiBuildStatusUpdater.new(BigtunaCiProjectStatusReader.new)
		# build_status_updater.update(updater)
	end
end

# scheduler.every '1h' do
scheduler.every '30s' do
	updater.update_part(:hours) do |updater|
		raise "test error"
		
		sleep 7.5
		# hours_updater = HoursLoggedUpdater.new(FreckleHoursLoggedReader.new)
		# hours_updater.update(updater)
	end
end

expect_interrupt do
	scheduler.join
end
