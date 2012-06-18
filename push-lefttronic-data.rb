#!ruby
# encoding: utf-8

require './bigtuna-ci-project-statuses'

require 'leftronic'

build_project_name_widgets = {
	"Project A" => 'ESlemK7N',
	"Project B" => 'WhsAHBM2',
	"Project C" => '9avuzLrP',
	"Project D" => '9U41swTM',
	"Project E" => 'QAWwnzHe',
	"Project F" => 'sqALqaQ6',
}

def build_status_to_rating(status)
	status_ratings = {
		failed: 100,
		in_progress: 50,
		ok: 0,
	}
	return status_ratings[status]
end

updater = Leftronic.new 'redacted'

project_statuses = get_project_statuses
project_statuses.each do |status|
	rating = build_status_to_rating( status[:build_status] )
	widget_id = build_project_name_widgets[status[:name]]
	updater.push_number widget_id, rating
end
