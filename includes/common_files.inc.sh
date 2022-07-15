#!/bin/bash

# MAKE SHARED LIBRARY FUNCTIONS AVAILABLE HERE

# in preference order
declare -a expected_lib_symlink_locations=(
	"${command_dirname}/shared-functions-library"
	'/usr/local/lib/lib10k'
	"${HOME}/.local/share/lib10k"	
	'.'
	'/usr/local/bin'
	
)

# Check whether SHARED_LIBRARIES_DIR has already been set (as an environment variable).
# If not try to assign value to SHARED_LIBRARIES_DIR by checking the expected symlink locations.
if [ -z "${SHARED_LIBRARIES_DIR}" ]
then
	for dir in ${expected_lib_symlink_locations[@]}
	do
		if [ -d "$dir" ] && \
		[ -f "${dir}/shared-bash-functions.inc.sh" ] && \
		[ -f "${dir}/shared-bash-constants.inc.sh" ]
		then
			SHARED_LIBRARIES_DIR="$dir"
			shared_bash_functions_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-functions.inc.sh"
			shared_bash_constants_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-constants.inc.sh"
			break
		fi
	done 	
fi

# SHARED_LIBRARIES_DIR variable should now have been either \
# found or had value assigned.
# If not, native exit.
# If so, source lib files.
if [ -n "${SHARED_LIBRARIES_DIR}" ]
then
	source "$shared_bash_functions_fullpath"
	source "$shared_bash_constants_fullpath"
else
	echo "Could not find the required libraries for this program. Exit program."
	exit 1
fi

