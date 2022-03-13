<div id="top"></div>
<h3 align="center">Proxy Firefox</h3>

  <p align="center">
    A quick way to start and stop an SSH proxy for a Firefox session.
</div>
<!-- ABOUT THE PROJECT -->
## About The Project

<!-- GETTING STARTED -->
## Getting Started

Download the script, `chmod`, then change the lines at the top to match your needs.

`chmod u+x proxy-firefox.sh; vi proxy-firefox.sh`


```
# The remote machine, and user to use. The user can be left blank if you have it set in ~/.ssh/config
remote_host="bar"
remote_user=

# The path to the identity file, if you haven't set the file via your ~/.ssh/config
# Otherwise, it makes sense to just leave this blank.
# remote_identity_file=~/.ssh/id_ed25519
remote_identity_file=

# A free open port we can use for our SOCKS proxy.
local_proxy_port=8192

# Setting this to "localhost" will allow people on your local network to connect to your proxy, too.
# making "localhost" probably a bad choice.
local_proxy_address="127.0.0.1"

# The profile name we want to create, it's advisable NOT to use 'default', as it will set options
# on your profile that might be annoying to reverse.
firefox_profile="ssh-proxied"
firefox_profile_directory=~/.mozilla/firefox

# A comma seperated list of addresses not to proxy.
not_proxied="localhost, 127.0.0.1"
```


## New Features I'm Intending to add

It seems reasonably simple to add a .desktop entry by simply copying the existing one, and adding a new action. I believe this will work for 