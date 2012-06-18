#!ruby
# encoding: utf-8

require './bigtuna-ci-project-statuses'

require 'leftronic'

build_project_id_widgets = {
	1 => 'ESlemK7N', # Project A
	2 => 'WhsAHBM2', # Project B
	3 => '9avuzLrP', # Project C
	4 => '9U41swTM', # Project D
	5 => 'QAWwnzHe', # Project E
	6 => 'sqALqaQ6', # Project F
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
	widget_id = build_project_id_widgets[status[:id_num]]
	updater.push_number widget_id, rating
end
