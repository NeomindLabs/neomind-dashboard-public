#!ruby
# encoding: utf-8

require './bigtuna-ci-project-statuses'

require 'leftronic'

build_project_name_widget_ids = {
	"Project A" => 'ESlemK7N',
	"Project B" => 'WhsAHBM2',
	"Project C" => '9avuzLrP',
	"Project D" => '9U41swTM',
	"Project E" => 'QAWwnzHe',
	"Project F" => 'sqALqaQ6',
}

build_status_ratings = {
	failed: 100,
	in_progress: 50,
	ok: 0,
}

access_key = 'redacted'
updater = Leftronic.new access_key

project_statuses = get_project_statuses
project_statuses.each do |status|
	rating = build_status_ratings[ status[:build_status] ]
	widget_id = build_project_name_widget_ids[ status[:name] ]
	updater.push_number widget_id, rating
end
