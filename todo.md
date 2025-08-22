# TODO

- fix bug where many waybars are spawned after a while in locked state (has something to do with monitors, dpms?) 
- Remove duplicates in multiple /application directories for fzf-launcher
- Document or automate the Firefox profile with the userchrome.css. Either in the AI window script or in Ansible.
- document the 'need' for pywalfox
- set gtk themes programmatically, without nwg-look (can stay as an extra optional dependecy)
- multimonitor with hyprwatcher
    - Enable systemd service hypr-watcher in setup script
- `xdg-mime default helix.desktop text/plain` and change /usr/share/applications/helix.desktop so that it execs `foot helix` instead of helix, so it can also start from launcher (and when I open local URL links in terminal!)
