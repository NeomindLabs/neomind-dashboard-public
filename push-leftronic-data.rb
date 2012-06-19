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
	build_project_name_stream_names = {
		"Project A" => 'project_a_ci_status',
		"Project B" => 'project_b_ci_status',
		"Project C" => 'project_c_ci_status',
		"Project D" => 'project_d_ci_status',
		"Project E" => 'project_e_ci_status',
		"Project F" => 'project_f_ci_status',
	}
	
	project_statuses = get_project_statuses
	project_statuses.each do |status|
		rating = build_status_ratings[ status[:build_status] ]
		raise "unknown build status" if rating.nil?
		stream_name = build_project_name_stream_names[ status[:name] ]
		raise "CI project has no corresponding stream" if stream_name.nil?
		updater.push_number stream_name, rating
	end
end

def update_freckle_hours(updater)
	freckle_stream_name = 'freckle_daily_hours'
	
	data_points = (0..7).map do |days_ago|
		date = Date.today.prev_day(days_ago)
		hours_logged = get_total_hours_logged_on(date)
		
		normalized_date = date.to_time.utc
		unix_timestamp = normalized_date.strftime('%s').to_i
		data_point = {number: hours_logged, timestamp: unix_timestamp, suffix: " hours"}
		data_point
	end.reverse
	pp data_points
	
	updater.clear(freckle_stream_name)
	updater.push_number(freckle_stream_name, data_points)
end

def update_leftronic_update_status(updater, status)
	status_stream_name = 'updater_script_status'
	status_ratings = {:success => 0, :in_progress => 50, :error => 100}
	updater.push_number status_stream_name, status_ratings[status]
end

access_key = 'redacted'
updater = Leftronic.new access_key
begin
	update_leftronic_update_status(updater, :in_progress)
	# update_build_statuses(updater)
	update_freckle_hours(updater)
	update_leftronic_update_status(updater, :success)
rescue Exception
	update_leftronic_update_status(updater, :error)
	raise
end
