# TODO

- fix bug where many waybars are spawned after a while in locked state (has something to do with monitors, dpms?) 
- add .zshrc symlink to ansible (symlink farm manager?)
- Remove duplicates in multiple /application directories for fzf-launcher
- Document or automate the Firefox profile with the userchrome.css. Either in the AI window script or in Ansible.
- Add symlink for wallpapers in home dir in script (dont forget automatic backup)
- document the 'need' for pywalfox
- set gtk themes programmatically, without nwg-look (can stay as an extra optional dependecy)
- use normal bash script instead of ansible... (idempotic pls!)
- multimonitor with hyprwatcher
    - Enable systemd service hypr-watcher in setup script
- Dash as dependency + dashbinsh (just contains pacman hook to reset /bin/sh symlink to /bin/dash when bash updates)
- add .gitconfig symlink in script
- Add git-delta as dependency
- `xdg-mime default helix.desktop text/plain` and change /usr/share/applications/helix.desktop so that it execs `foot helix` instead of helix, so it can also start from launcher (and when I open local URL links in terminal!)
- Add dependency `vscode-css-languageserver` for css in helix
