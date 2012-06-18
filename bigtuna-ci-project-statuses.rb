#!ruby
# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'pp'

url = "redacted"
doc = Nokogiri::HTML(open(url))
projects = doc.css('.project')

project_statuses = projects.map do |project|
	
	id = project.attr('id') #=> "project_6"
	id_num = id.match(/\d+/).to_s
	
	name = project.at_css('h3 a').content.strip
	
	classes = project.attr('class').split #=> "status_build_failed project"
	build_status_class = classes[classes.find_index { |klass| klass.start_with?('status_build_') }]
	status = build_status_class.sub('status_build_', '').to_sym
	
	{id_num: id_num, name: name, build_status: status}
end
project_statuses.sort_by! { |status| status[:id_num] }

pp project_statuses
