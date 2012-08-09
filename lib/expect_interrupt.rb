# encoding: utf-8

# execute the block assuming that interrupting to exit is normal, not an exception
def expect_interrupt
	begin
		yield
	rescue Interrupt
		puts # to separate the typed `^C` from upcoming program output or shell prompt
	end
end
