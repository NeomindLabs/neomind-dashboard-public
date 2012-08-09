# encoding: utf-8

module ExceptionPrinting
	module BlockWrapper
		class << self
			def wrap(&block)
				return Proc.new do |*args_for_block_call|
					begin
						block.call(*args_for_block_call)
					rescue Exception => ex
						print_exception(ex)
						nil
					end
				end
			end
			
			private
			
			def print_exception(ex)
				$stderr.puts "#{ex.class}: #{ex.message}", ex.backtrace
			end
		end
	end
	
	module BlockCaller
		class << self
			def call(*args_for_block_call, &block)
				exception_printing_block = BlockWrapper.wrap(&block)
				exception_printing_block.call(*args_for_block_call)
			end
		end
	end
	
	# a way to create a thread that lets you #join the thread without possibility of raising an exception past that
	module ThreadBuilder
		class << self
			def new_thread(*args_for_thread_new, &block)
				exception_printing_block = BlockWrapper.wrap(&block)
				Thread.new(*args_for_thread_new, &exception_printing_block)
			end
		end
	end
end
