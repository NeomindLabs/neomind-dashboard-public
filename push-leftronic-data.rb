#!ruby
# encoding: utf-8

require './bigtuna-ci-project-statuses'
require './freckle-hours-worked'

require 'leftronic'

def update_build_statuses(updater)
	build_status_ratings = {
		failed: 100,
		in_progress: 50,
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
		widget_id = build_project_name_widget_ids[ status[:name] ]
		updater.push_number widget_id, rating
	end
end

def update_freckle_hours(updater)
	freckle_widget_id = 'IriiyIFP'
	
	# updater.push_number widget_id, a_number
end

access_key = 'redacted'
updater = Leftronic.new access_key
# update_build_statuses(updater)
update_freckle_hours(updater)
