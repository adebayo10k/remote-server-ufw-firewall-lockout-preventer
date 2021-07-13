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

##################################################################
##################################################################
# THIS STUFF IS HAPPENING BEFORE MAIN FUNCTION CALL:
#===================================

# 1. MAKE SHARED LIBRARY FUNCTIONS AVAILABLE HERE

# make all those library function available to this script
shared_bash_functions_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-functions.sh"
shared_bash_constants_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-constants.inc.sh"

for resource in "$shared_bash_functions_fullpath" "$shared_bash_constants_fullpath"
do
	if [ -f "$resource" ]
	then
		echo "Required library resource FOUND OK at:"
		echo "$resource"
		source "$resource"
	else
		echo "Could not find the required resource at:"
		echo "$resource"
		echo "Check that location. Nothing to do now, except exit."
		exit 1
	fi
done


# 2. MAKE SCRIPT-SPECIFIC FUNCTIONS AVAILABLE HERE

# must resolve canonical_fullpath here, in order to be able to include sourced function files BEFORE we call main, and  outside of any other functions defined here, of course.

# at runtime, command_fullpath may be either a symlink file or actual target source file
command_fullpath="$0"
command_dirname="$(dirname $0)"
command_basename="$(basename $0)"

# if a symlink file, then we need a reference to the canonical file name, as that's the location where all our required source files will be.
# we'll test whether a symlink, then use readlink -f or realpath -e although those commands return canonical file whether symlink or not.
# 
canonical_fullpath="$(readlink -f $command_fullpath)"
canonical_dirname="$(dirname $canonical_fullpath)"

# this is just development debug information
if [ -h "$command_fullpath" ]
then
	echo "is symlink"
	echo "canonical_fullpath : $canonical_fullpath"
else
	echo "is canonical"
	echo "canonical_fullpath : $canonical_fullpath"
fi

# included source files for json profile import functions
#source "${canonical_dirname}/preset-profile-builder.inc.sh"


# THAT STUFF JUST HAPPENED (EXECUTED) BEFORE MAIN FUNCTION CALL!
##################################################################
##################################################################


function main 
{
################################################################
	# GLOBAL VARIABLE DECLARATIONS:
################################################################

	exec_dir='/usr/local/bin'
	ufw_testing_dir='ufw-testing'
	mkdir -p "$exec_dir/$ufw_testing_dir"
	# create reference to a log file	
	ufw_disable_log="$exec_dir/$ufw_testing_dir/just-testing-ufw.log"

	PRECONDITIONS_OK=

################################################################
	# FUNCTION CALLS:
################################################################

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
		# exit with wrong preconditions message
		echo "wrong preconditions exist, so exiting now"
		exit 0
	else
		# exit with error failsafe branch
		exit 1
	fi

	echo | tee -a "$ufw_disable_log"
	# postcondition for this program is that ufw is disabled
	echo "postcondition needed	:	disabled" | tee -a "$ufw_disable_log"
	do_postcondition_test

} ## end main


################################################################
	# FUNCTION DECLARATIONS:
################################################################

function do_precondition_test ()
{
	isActive=42 # reset

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
		echo "Go ahead and entrust this program to cron"
	else
		echo "postcondition found	:	enabled" | tee -a "$ufw_disable_log"
		echo "postcondition test	:	failed" | tee -a "$ufw_disable_log"
		echo "Don't pass control of this program to the cron yet!"
	fi
}


main "$@"; exit