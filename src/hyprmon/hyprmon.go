package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

const (
	HyprctlPath    = "/usr/bin/hyprctl"
	MonitorCfgPath = ".config/hypr/monitors.conf" // $HOME must still be appended
)

type Monitor struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Disabled    bool   `json:"disabled"`

	ToEnable bool // Not from hyprctl, for internal use
}

// Get the state of the currently connected monitors.
func getConnectedMonitors() []Monitor {
	stdout, err := exec.Command(HyprctlPath, "monitors", "all", "-j").Output()
	if err != nil {
		die("hyprctl failed: " + err.Error())
	}

	var connectedMons []Monitor
	if err := json.Unmarshal(stdout, &connectedMons); err != nil {
		die("JSON parse error: " + err.Error())
	}

	return connectedMons
}

// Enable/disable monitors based on the ToEnable field of entries in `mons`.
func toggleMonitors(mons []Monitor) error {
	if len(mons) == 0 {
		return nil
	}

	var b strings.Builder

	for _, monitor := range mons {
		if monitor.Disabled != monitor.ToEnable {
			continue // Monitor is already in the desired state
		}

		b.WriteString("keyword monitor desc:")
		b.WriteString(monitor.Description)
		b.WriteRune(',')
		if monitor.ToEnable {
			b.WriteString("enable")
		} else {
			b.WriteString("disable")
		}
		b.WriteString(" ; ")
	}

	if b.Len() > 0 {
		return nil // no command to emit
	}
	return exec.Command(HyprctlPath, "--batch", b.String()).Run()
}

func main() {
	if len(os.Args) != 2 {
		die("Usage: monitorctl N")
	}
	numberOfMonsToEnable, err := strconv.Atoi(os.Args[1])
	if err != nil || numberOfMonsToEnable < 1 {
		die("Error: N must be integer > 0")
	}

	cfgPath := filepath.Join(os.Getenv("HOME"), MonitorCfgPath)
	f, err := os.Open(cfgPath)
	if err != nil {
		die("Cannot open monitors.conf: " + err.Error())
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	monitors := getConnectedMonitors()

	for scanner.Scan() && numberOfMonsToEnable > 0 {
		line := strings.TrimSpace(scanner.Text())
		if !strings.HasPrefix(line, "monitor") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) < 2 {
			continue
		}

		name := strings.TrimSpace(strings.SplitN(parts[1], ",", 2)[0])
		desc, found := strings.CutPrefix(name, "desc:")
		if found {
			// search based on description
			for i := range monitors {
				if monitors[i].Description == desc {
					monitors[i].ToEnable = true
					numberOfMonsToEnable--
					break
				}
			}
		} else {
			// search based on name
			for i := range monitors {
				if monitors[i].Name == name {
					monitors[i].ToEnable = true
					numberOfMonsToEnable--
					break
				}
			}
		}
	}

	// If we STILL need to enable more monitors; turn to unknown but connected ones, at random
	for i := range monitors {
		if numberOfMonsToEnable <= 0 {
			break
		}
		if !monitors[i].ToEnable {
			monitors[i].ToEnable = true
			numberOfMonsToEnable--
		}
	}

	err = toggleMonitors(monitors)
	if err != nil {
		die("Could not toggle monitor state: " + err.Error())
	}
}

func die(msg string) {
	fmt.Fprintln(os.Stderr, msg)
	os.Exit(1)
}
