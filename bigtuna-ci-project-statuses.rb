# encoding: utf-8

require './config-loader'

require 'nokogiri'
require 'open-uri'
require 'pp'

class BigTunaCiProjectStatusReader
	CONFIG = ConfigLoader.new.config_for("BigTuna CI")
	
	# get project basic info and build statuses (all tests pass, some tests failed, in build queue, etc.)
	def get_statuses
		url = CONFIG["statuses URL"]
		doc = Nokogiri::HTML(open(url))
		projects = doc.css('.project')
		
		project_statuses = projects.map do |project|
			{
				id_num: begin
					id = project.attr('id') #=> "project_6"
					id.match(/\d+/).to_s.to_i
				end,
				name: begin
					project.at_css('h3 a').content.strip
				end,
				build_status: begin
					classes = project.attr('class').split #=> "status_build_failed project"
					build_status_class = classes[classes.find_index { |klass| klass.start_with?('status_') }]
					build_status_class.sub('status_', '').to_sym
				end,
			}
		end
		
		return project_statuses.sort_by { |status| status[:id_num] }
	end
end

if __FILE__ == $0 # if this file is run directly
	project_statuses = BigTunaCiProjectStatusReader.new.get_statuses
	pp project_statuses
end
