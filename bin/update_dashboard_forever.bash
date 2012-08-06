#!/bin/bash

# update the whole dashboard, periodically, forever

seconds_between_updates=3600 # 1 hour in seconds

while true
do
	date
	./update_dashboard_now.bash
	sleep $seconds_between_updates
done
