#!ruby
# encoding: utf-8

require './bigtuna-ci-project-statuses'
require './freckle-hours-worked'

require './leftronic/ruby/leftronic'
require 'date'

def update_build_statuses(updater)
	build_status_ratings = {
		failed: 100,
		in_progress: 50,
		in_queue: 50,
		ok: 0,
	}
	build_project_name_widget_ids = {
		"Project A" => 'ESlemK7N',
		"Project B" => 'WhsAHBM2',
		"Project C" => '9avuzLrP',
		"Project D" => '9U41swTM',
		"Project E" => 'QAWwnzHe',
		"Project F" => 'sqALqaQ6',
	}
	
	project_statuses = get_project_statuses
	project_statuses.each do |status|
		rating = build_status_ratings[ status[:build_status] ]
		raise "unknown build status" if rating == nil
		widget_id = build_project_name_widget_ids[ status[:name] ]
		raise "CI project has no corresponding widget"
		updater.push_number widget_id, rating
	end
end

def update_freckle_hours(updater)
	freckle_widget_id = '7qt5xKcc'
	
	data_points = (0...7).map do |days_ago|
		date = Date.today.prev_day(days_ago)
		hours_logged = get_total_hours_logged_on(date)
		
		unix_timestamp = date.strftime('%s').to_i
		data_point = {number: hours_logged, timestamp: unix_timestamp, suffix: " hours"}
		data_point
	end.reverse
	pp data_points
	updater.push_number(freckle_widget_id, data_points)
end

def update_leftronic_update_status(updater, succeeded)
	status_widget_id = 'edyTl2k8'
	success_ratings = {true => 0, false => 100}
	updater.push_number status_widget_id, success_ratings[succeeded]
end

access_key = 'redacted'
updater = Leftronic.new access_key
begin
	# update_build_statuses(updater)
	update_freckle_hours(updater)
	update_leftronic_update_status(updater, true)
rescue Exception
	update_leftronic_update_status(updater, false)
	raise
end
