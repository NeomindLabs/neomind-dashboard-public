# encoding: utf-8

require_relative 'config_loader'

module UpdateStatusHtmlGenerator
	CONFIG = ConfigLoader.new.config_for("updater script")
	
	def html_explanation_of_status(status)
		case status
		when :success
			success_html_explanation
		when :in_progress
			in_progress_html_explanation
		when :error
			error_html_explanation
		end
	end
	
	private
	
	def medium_term_time_string
		# time format: "Wed 2:34 PM"
		Time.now.strftime '%a %-l:%M %p'
	end
	
	def short_term_time_string
		# time format: "2:34 PM"
		Time.now.strftime '%-l:%M %p'
	end
	
	def camouflaged_link_to_script_code(link_text)
		script_code_url = CONFIG["code URL"]
		surrounding_text_color = '#CCC'
		
		'<a href="'+script_code_url+'" style="color: '+surrounding_text_color+'">'+link_text+'</a>'
	end
	
	def html_of_time_with_header(header_body)
		header = "<h2>#{header_body}:</h2>"
		section_separator = "\n\n"
		time_html = "<div>#{medium_term_time_string}</div>"
		
		return header + section_separator + time_html
	end
end
