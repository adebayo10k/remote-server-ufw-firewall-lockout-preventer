remote-server-ufw-firewall-lockout-preventer
===
ufw (uncomplicated firewall) is a layer 2 firewall with which we can create rulesets to allow and deny IP traffic.
ufw does a great job of warning us if we're about to remove the wrong ssh allow rule during an ssh session -
but as wise person once said... "never say never".

This program was tested on Ubuntu (20.04) Linux and RPi Raspbian servers, with their BASH interpreters.

Files
===
remote-ufw-lockout-preventer.sh - main script file

Purpose
===
The main script file basically contains three functions.

do_precondition_test()  - checks whether or not the firewall is currently active.
disable_ufw() - then disables the firewall (depending on outcome from first function).
do_postcondition_test() - then verifies the firewall state if the second function was executed.

Each function sends output to both console and a log file (/usr/local/bin/ufw-testing/just-testing-ufw.log).

So basically, if the firewall is already disabled, there is nothing to do, so the program just logs those findings and exits gracefully. If the firewall was found enabled, the program disables it and logs. This repeats at intervals you define in your crontab.

Dependencies
===
shared-bash-functions.inc.sh - common functions library in [link to repo]
shared-bash-constants.inc.sh - common constants library in [link to repo]

Prerequisites
===
This program is used to control the state of the ufw. You'll therefore need to have ufw already installed. 
This program runs as the root super user and must be installed by the root admin (sudo) user. The ufw also requires root admin level user privilege.


Installation on a development server
===
0. Clone the required repositories

git clone https://github.com/adebayo10k/shared-functions-library.git
git clone https://github.com/adebayo10k/remote-server-ufw-firewall-lockout-preventer.git

1. Install the shared libraries if not already installed

Install the share libraries with the following commands:

cd /path/to/your/git-cloned/shared-functions-library/
./shared-bash-functions.inc.sh && ./shared-bash-constants.inc.sh

EXPECTED OUTPUT:

Depending on whether the script has been run previously, something like:

The symbolic link [/home/user/.local/share/lib10k/shared-bash-functions.inc.sh] already exists OK

Creating symbolic link:
TARGET	: /home/user/bin/utils/shared-functions-library/shared-bash-functions.inc.sh
LINK	: /usr/local/lib/lib10k/shared-bash-functions.inc.sh

The symbolic link [/home/user/.local/share/lib10k/shared-bash-constants.inc.sh] already exists OK

Creating symbolic link:
TARGET	: /home/user/bin/utils/shared-functions-library/shared-bash-constants.inc.sh
LINK	: /usr/local/lib/lib10k/shared-bash-constants.inc.sh

The above shared libraries installation only need be done once, although it is idempotent in any case.

2. Manually create a symbolic link to the remote-ufw-lockout-preventer.sh script in your local git repository target,  from a symbolic link file in usr/local/bin/:

sudo ln -s /path/to/your/git-cloned/remote-ufw-lockout-preventer.sh /usr/loca/bin/remote-ufw-lockout-preventer.sh

Configuration
===
None.

Parameters
===
None.

Testing the Script on a development server
===
Although the point of this program is to run as a root cron job, you'll probably want to test it by hand first, before handing it over to root cron. Doing this gives us some immediate feedback from the program to our console.

After installation, to test on a development server, execute the commands:

0. Enable ufw with the command:

sudo ufw enable

1. Execute the program with the command:

sudo remote-ufw-lockout-preventer.sh

If successful, the output to terminal should confirm that firwall was disabled:

precondition needed	:	enabled
precondition found	:	enabled
precondition test	:	passed

postcondition needed	:	disabled
postcondition found	:	disabled
postcondition test	:	passed
Go ahead and entrust this program to cron

2. Now create a root user crontab entry to schedule the script's excution:

sudo crontab -e

0,15,30,45 * * * * bash  "/usr/local/bin/remote-ufw-lockout-preventer.sh" >/dev/null 2>>/usr/local/bin/cronjob-errors.log

The stdout and stderr streams here refer to the cron program, not ours.

3. Again, enable ufw with the command:

sudo ufw enable

4. After cron has run the program, check the log produced in /usr/local/bin/ufw-testing/just-testing-ufw.log

Installation on remote server
===
Again, you'll need to have sudo privileges on the server.
This time copy library files directly same directory (/usr/local/bin) on the remote server. No need to create symbolic links back to git repos here! You can just delete these script files (and the log file) when finished. Files to copy over are:

remote-ufw-lockout-preventer.sh
shared-bash-functions.inc.sh
shared-bash-constants.inc.sh

Running the Script on remote server
===

Follow the same step taken in "Testing the Script on a development server".


Logging
===
/usr/local/bin/ufw-testing/just-testing-ufw.log

Typical outputs show what action the program has taken:

Tue 29 Jun 12:05:01 BST 2021

precondition needed     :       enabled
precondition found      :       enabled
precondition tests      :       passed
Firewall stopped and disabled on system startup


postcondition needed    :       disabled
postcondition found     :       disabled
postcondition test      :       passed

Tue 29 Jun 12:10:01 BST 2021

precondition needed     :       enabled
precondition found      :       disabled
precondition tests      :       failed

Wed  8 Jun 20:30:01 BST 2022

precondition needed     :       enabled
precondition found      :       disabled
precondition test       :       failed
just-testing-ufw.log (END)





License
===




Contact
===

