# encoding: utf-8

require 'letsfreckle'
require 'date'
require 'pp'

# calculate total hours logged for the given date
def get_total_hours_logged_on(date)
	LetsFreckle.configure do
		account_host 'redacted'
		username 'redacted'
		token 'redacted'
	end
	
	date_for_freckle = date.strftime('%F')
	entries_on_that_date = LetsFreckle::Entry.find(from: date_for_freckle, to: date_for_freckle)
	entries_hours = entries_on_that_date.map do |entry|
		minutes_to_hours(entry.minutes)
	end
	total_hours = entries_hours.reduce(0, &:+)
	return total_hours
end

def minutes_to_hours(minutes)
	return minutes.to_f / 60
end

if __FILE__ == $0 # if this file is run directly
	total_hours_logged = get_total_hours_logged_on(Date.today)
	puts "hours worked today, so far:"
	pp total_hours_logged
	
	puts "loading past data…"
	range_of_past_days = (0..7)
	daily_counts = range_of_past_days.map do |days_ago|
		date = Date.today.prev_day(days_ago)
		puts days_ago.to_s + "…"
		hours_logged = get_total_hours_logged_on(date)
	end
	pp daily_counts
	puts "maximum hours worked in that time period:", daily_counts.max
end
