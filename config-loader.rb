# encoding: utf-8

require 'yaml'

class ConfigLoader
	def initialize
		load_config_data
	end
	
	def [](name)
		config_for(name)
	end
	
	def config_for(name)
		@config_data[name]
	end
	
	private
	
	def load_config_data
		config_file_path = 'config/config.yml'
		begin
			config_file_contents = File.read(config_file_path)
		rescue Errno::ENOENT
			$stderr.puts "missing config file"
			raise
		end
		@config_data = YAML.load(config_file_contents)
	end
end

if __FILE__ == $0 # if this file is run directly
	puts "the configuration for just the updater script:"
	puts ConfigLoader.new.config_for("updater script")
end
