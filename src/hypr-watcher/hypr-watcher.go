package main

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
	"os/exec"
	"strings"
)

type HandlerFunc func(event Event)

type EventHandler struct {
	Name       string
	EventTypes []string
	Func       HandlerFunc
}

type Event struct {
	Type string
	Data string
}

var eventHandlers = []EventHandler{
	{
		Name:       "Monitor manager",
		EventTypes: []string{"monitorremovedv2", "monitoraddedv2"},
		Func: func(event Event) {
			cmd, err := exec.LookPath("hyprmon")
			if err != nil {
				fmt.Printf("Error: could not find find hyprmon: %v\n", err)
			}
			out, err := exec.Command(cmd, "1").CombinedOutput()
			if err != nil {
				fmt.Printf("Error while executing hyprmon: %v: %s\n", err, out)
			}
		},
	},
}

func main() {
	// Create socket address
	signature := os.Getenv("HYPRLAND_INSTANCE_SIGNATURE")
	if signature == "" {
		log.Fatal("$HYPRLAND_INSTANCE_SIGNATURE not set")
	}
	xdgRuntimeDir := os.Getenv("XDG_RUNTIME_DIR")
	if xdgRuntimeDir == "" {
		log.Fatal("$XDG_RUNTIME_DIR nog set")
	}
	socketPath := fmt.Sprintf("%v/hypr/%v/.socket2.sock", xdgRuntimeDir, signature)

	// Connect to socket
	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		log.Fatalf("Failed to connect to Hyprland socket: %v", err)
	}
	defer conn.Close()
	log.Printf("Connected to Hyprland event socket: %v", socketPath)

	// Build map of handler functions
	handlerMap := map[string][]EventHandler{}
	for _, handler := range eventHandlers {
		for _, eventType := range handler.EventTypes {
			handlerMap[eventType] = append(handlerMap[eventType], handler)
		}
	}

	// Main event loop
	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		eventString := scanner.Text()
		eventStrParts := strings.SplitN(eventString, ">>", 2)
		if len(eventStrParts) != 2 {
			log.Printf("Received invalid event, skipping: %v", eventString)
			continue
		}
		event := Event{Type: eventStrParts[0], Data: eventStrParts[1]}
		for _, handler := range handlerMap[event.Type] {
			go handler.Func(event)
			log.Printf("Dispatched event %v to handler %v", event.Type, handler.Name)
		}
	}
	if err := scanner.Err(); err != nil {
		log.Fatalf("Error reading event: %v", err)
	}
}
