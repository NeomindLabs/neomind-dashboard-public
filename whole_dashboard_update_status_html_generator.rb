# encoding: utf-8

require './update_status_html_generator'

module WholeDashboardUpdateStatusHtmlGenerator
	extend UpdateStatusHtmlGenerator
	
	private
	
	class << self
		def success_html_explanation
			html_of_time_with_header("Dashboard last "+camouflaged_link_to_script_code("updated"))
		end
		
		def in_progress_html_explanation
			"Updating dashboard (#{short_term_time_string})…"
		end
		
		def error_html_explanation
			html_of_time_with_header("Dashboard "+camouflaged_link_to_script_code("update")+" failed")
		end
	end
end
