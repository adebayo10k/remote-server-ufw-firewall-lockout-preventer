#!/bin/bash

# never say never. WTF moments happen to us all.
# this simple script is just an insurance against locking ourselves out of a 
# remote host while configuring it's firewall.
# during remote ufw configuation the script runs on the remote server as 
# root cronjob to disable the firewall every 30 minutes. Perhaps like:

# intermittently disable firewall during testing and troubleshooting
#0,30 * * * * bash  "/usr/local/bin/remote-ufw-lockout-preventer.sh" >/dev/null 2>>/usr/local/bin/cronjob-errors.log

# the cronjob can be commented out or removed when testing is complete.

exec_dir='/usr/local/bin'
ufw_testing_dir='ufw-testing'

# create an ufw testing directory to store this programs' log
mkdir -p "$exec_dir/$ufw_testing_dir"
ufw_disable_log="$exec_dir/$ufw_testing_dir/just-testing-ufw.log"

# full path to /usr/sbin/ufw, as root doesn't have the honour of our $PATH
# run /usr/sbin/ufw and send stdout/stderr to our log file
echo "$(date)" >> "$ufw_disable_log"
/usr/sbin/ufw disable >> "$ufw_disable_log" 2>&1
echo >> "$ufw_disable_log"

# now set your alarm!