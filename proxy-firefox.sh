#!/bin/bash
#Author: Parker Jones <knotapun@gmail.com>
#Written: 2022-03-12

#The username and password to use on the remote machine.
remote_user="AVeryUnlikelyUsername"
remote_host="AVeryUnlikelyHostname"

#The path to the identity file, if you haven't set the file via your ~/.ssh/config folder.
#remote_identity_file=~/.ssh/id_ed25519
remote_identity_file=

local_proxy_port=8192
local_proxy_address="127.0.0.1"

# The profile name we want to create, it's advisable NOT to use 'default' or really, any existing profile.
firefox_profile="ssh-proxied"
firefox_profile_directory=~/.mozilla/firefox

# A comma seperated list of addresses not to proxy.
not_proxied="localhost, 127.0.0.1"

IReallyUseThatUserOrHost=0




function get_profile() {      
  found_profile=$(find ${firefox_profile_directory}/*\.${firefox_profile} -maxdepth 0 -type d -printf "%f\n" 2> /dev/null)
}
found_profile=""
get_profile


# fastfail for missing FireFox
ff_exec=$(which firefox)
if [[ -z "${ff_exec}" ]]; then
  echo "This script expects firefox to be installed and accessible."
  exit 2; # No firefox install.
fi


# fastfail for missing ssh
ssh_exec=$(which ssh)
if [[ -z "${ssh_exec}" ]]; then
  echo "This script expects ssh to be installed and accessible. Where are you running bash without ssh?"
  exit 3; # No ssh accessible.
fi


# Check for profile
if [[ -z ${found_profile} ]]; then 
  echo "Couldn't find the profile '${firefox_profile}' in ${firefox_profile_directory}'"
  echo "Trying to create profile '${firefox_profile}'"
  firefox -createprofile "${firefox_profile}" --no-remote &>/dev/null
  echo "Called firefox to create profile, sleeping to ensure it gets done."
  sleep 2;
  get_profile
  if [[ -z ${found_profile} ]]; then
    echo "Failed to get the profile again, something is wrong with the script. Does '${firefox_profile_directory}' exist? Is it actually the firefox profile directory?"
    exit 5; # Couldn't create profile.
  fi
fi


#Assemble user.js string.
user_conf="" #This is only here to keep the spacing consistent.
user_conf="${user_conf} user_pref(\"network.proxy.socks\", \"${local_proxy_address}\");"
user_conf="${user_conf} user_pref(\"network.proxy.socks_port\", ${local_proxy_port});"
user_conf="${user_conf} user_pref(\"network.proxy.socks_remote_dns\", true);"
user_conf="${user_conf} user_pref(\"network.proxy.type\", 1);"
user_conf="${user_conf} user_pref(\"signon.autologin.proxy\", true);"
user_conf="${user_conf} user_pref(\"network.proxy.no_proxies_on\", \"${not_proxied}\");"


# Write user.js
echo "${user_conf}" > "${firefox_profile_directory}/${found_profile}/user.js"


if [[ ! -f "${firefox_profile_directory}/${found_profile}/user.js" ]]; then
  echo "Couldn't write to '${firefox_profile_directory}/${found_profile}/user.js', which is used for proxy config. Lacks permissions, maybe?" 
  exit 6; # Couldn't write user.js
fi


#ssh -D <port> -q -C -N -f <user@host> 
# -2 - Use only ssh protocol 2
# -D - open a SOCKS proxy on the local port <port>
# -q - Quiet, produce no output
# -C - Compress Data
# -N - Do not execute commands.
# -f - fork/Run in background.

# Start ssh
ssh -2 -D ${local_proxy_address}:${local_proxy_port} -C -N -f ${remote_user}@${remote_host};
exit_code=$?


if [[ $exit_code -ne 0 ]]; then
  echo "ssh failed to connect. Not starting firefox."
  exit 7; #ssh didn't run.
fi


( firefox -no-remote -P "${firefox_profile}" &>/dev/null; \
  kill "$(lsof -i :${local_proxy_port} -P -n -a -u ${USER:-$USERNAME} -c ssh -t)"; \
  exit 0 ) &
