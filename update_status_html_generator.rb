# encoding: utf-8

require './config_loader'

module UpdateStatusHtmlGenerator
	CONFIG = ConfigLoader.new.config_for("updater script")
	
	def self.html_explanation_of_status(status)
		case status
		when :success
			html_of_time_with_header("Dashboard last "+camouflaged_link_to_script_code("updated"))
		when :in_progress
			"Updating dashboard (#{short_term_time_string})…"
		when :error
			html_of_time_with_header("Dashboard "+camouflaged_link_to_script_code("update")+" failed")
		end
	end
	
	private
	
	def self.camouflaged_link_to_script_code(link_text)
		script_code_url = CONFIG["code URL"]
		surrounding_text_color = '#CCC'
		
		'<a href="'+script_code_url+'" style="color: '+surrounding_text_color+'">'+link_text+'</a>'
	end
	
	def self.html_of_time_with_header(header_body)
		header = "<h2>#{header_body}:</h2>"
		section_separator = "\n\n"
		time_html = "<div>#{medium_term_time_string}</div>"
		
		return header + section_separator + time_html
	end
	
	def self.medium_term_time_string
		# time format: "Wed 2:34 PM"
		Time.now.strftime '%a %-l:%M %p'
	end
	
	def self.short_term_time_string
		# time format: "2:34 PM"
		Time.now.strftime '%-l:%M %p'
	end
end
