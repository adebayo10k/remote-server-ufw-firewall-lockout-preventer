#!/bin/bash

#===================================================
# never say never. WTF moments happen to us all.
# this simple script is just an insurance against locking ourselves out of a 
# remote host while configuring it's firewall.
# during remote ufw configuation the script runs on the remote server as 
# root cronjob to disable the firewall every 30 minutes. Perhaps like:

# intermittently disable firewall during testing and troubleshooting
#0,30 * * * * bash  "/usr/local/bin/remote-ufw-lockout-preventer.sh" >/dev/null 2>>/usr/local/bin/cronjob-errors.log

# the cronjob can be commented out or removed when testing is complete.
#===================================================

## THIS STUFF IS HAPPENING BEFORE MAIN FUNCTION CALL:

command_fullpath="$(readlink -f $0)" 
command_basename="$(basename $command_fullpath)"
command_dirname="$(dirname $command_fullpath)"

for file in "${command_dirname}/includes"/*
do
	source "$file"
done

## THAT STUFF JUST HAPPENED (EXECUTED) BEFORE MAIN FUNCTION CALL!

function main 
{
##########################
# GLOBAL VARIABLE DECLARATIONS:
##########################
	program_title="remote-ufw-lockout-preventer"
	original_author="damola adebayo"
	program_dependencies=("ufw")

	declare -i max_expected_no_of_program_parameters=0
	declare -i min_expected_no_of_program_parameters=0
	declare -ir actual_no_of_program_parameters=$#
	all_the_parameters_string="$@"

	exec_dir='/usr/local/bin'
	ufw_testing_dir='ufw-testing'
	mkdir -p "$exec_dir/$ufw_testing_dir"
	# create reference to a log file	
	ufw_disable_log="$exec_dir/$ufw_testing_dir/just-testing-ufw.log"

	PRECONDITIONS_OK=

	##########################
	# FUNCTION CALLS:
	##########################
	if [ ! $USER = 'root' ]
	then
		## Display a program header
		lib10k_display_program_header "$program_title" "$original_author"
		## check program dependencies and requirements
		lib10k_check_program_requirements "${program_dependencies[@]}"
	fi
	
	# check the number of parameters to this program
	lib10k_check_no_of_program_args

	echo | tee -a "$ufw_disable_log"
	echo "$(date)" >> "$ufw_disable_log"

	echo | tee -a "$ufw_disable_log"
	# precondition for this program is that ufw is enabled
	echo "precondition needed	:	enabled" | tee -a "$ufw_disable_log"
	do_precondition_test

	if [[ "$PRECONDITIONS_OK" = 'PASSED'  ]]
	then
		echo "precondition test	:	passed" | tee -a "$ufw_disable_log"
		disable_ufw
	elif [[ "$PRECONDITIONS_OK" = 'FAILED'  ]]
	then
		echo "precondition test	:	failed" | tee -a "$ufw_disable_log"
		exit 0
	else
		msg="Failsafe branch entered error. Exiting now."
		lib10k_exit_with_error "E_UNEXPECTED_BRANCH_ENTERED" "$msg"
	fi

	echo | tee -a "$ufw_disable_log"
	# postcondition for this program is that ufw is disabled
	echo "postcondition needed	:	disabled" | tee -a "$ufw_disable_log"
	do_postcondition_test

} ## end main

##########################
	# FUNCTION DECLARATIONS:
##########################

function do_precondition_test ()
{
	isActive=42 # initialise to a fail state

	echo $(/usr/sbin/ufw status) | grep -q 'Status: active'
	isActive=$?
	# if the string 'Status: active' was detected in stdout...
	if [ $isActive -eq 0 ]	
	then
		PRECONDITIONS_OK='PASSED'
		echo "precondition found	:	enabled" | tee -a "$ufw_disable_log"
		
	else
		PRECONDITIONS_OK='FAILED'
		echo "precondition found	:	disabled" | tee -a "$ufw_disable_log"
	fi
	# check syslog when root runs, as echo output might need to be >/dev/null
}	

function disable_ufw ()
{
	# full path to /usr/sbin/ufw, as root doesn't use our $PATH
	# run /usr/sbin/ufw and send stdout/stderr to our log file
	/usr/sbin/ufw disable >> "$ufw_disable_log" 2>&1
	echo >> "$ufw_disable_log"	
}

# test whether the ufw disable command worked
function do_postcondition_test ()
{		
	if [[ "$(/usr/sbin/ufw status)" = 'Status: inactive'  ]]
	then
		echo "postcondition found	:	disabled" | tee -a "$ufw_disable_log"
		echo "postcondition test	:	passed" | tee -a "$ufw_disable_log"
		echo "Go ahead and entrust this program to your crontab"
	else
		echo "postcondition found	:	enabled" | tee -a "$ufw_disable_log"
		echo "postcondition test	:	failed" | tee -a "$ufw_disable_log"
		echo "Don't pass control of this program to the cron yet!"
	fi
}

main "$@"; exit