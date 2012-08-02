# encoding: utf-8

require './update_status_html_generator'

module SinglePartUpdateStatusHtmlGenerator
	extend UpdateStatusHtmlGenerator
	
	private
	
	class << self
		def success_html_explanation
			html_of_time_with_header("Last "+camouflaged_link_to_script_code("updated"))
		end
		
		def in_progress_html_explanation
			"Updating (#{short_term_time_string})…"
		end
		
		def error_html_explanation
			camouflaged_link_to_script_code("Update")+" at "+medium_term_time_string+" "+color_red("failed")+"!"
		end
		
		def color_red(text)
			'<span style="color: red">'+text+'</span>'
		end
	end
end
