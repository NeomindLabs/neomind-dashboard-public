# encoding: utf-8

require './config_loader'

require 'nokogiri'
require 'open-uri'

class BigtunaCiProjectStatusReader
	CONFIG = ConfigLoader.new.config_for("BigTuna CI")
	
	# get project basic info and build statuses (all tests pass, some tests failed, in build queue, etc.)
	def get_statuses
		# scrape the statuses web page (more convenient than looking up an API)
		
		url = CONFIG["statuses URL"]
		doc = Nokogiri::HTML( open(url) )
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
					build_status_class_common_prefix = 'status_'
					build_status_class = classes.find { |klass| klass.start_with?(build_status_class_common_prefix) }
					build_status_class.sub(build_status_class_common_prefix, '').to_sym
				end,
			}
		end
		
		return project_statuses.sort_by { |status| status[:id_num] }
	end
end

if __FILE__ == $0 # if this file is run directly
	require 'pp'
	
	project_statuses = BigtunaCiProjectStatusReader.new.get_statuses
	pp project_statuses
end
