package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/Kongeter/Chambord/socket"
	"golang.org/x/net/websocket"
)

func main() {
	fmt.Println("started")
	server := socket.NewServer()
	http.Handle("/ws", websocket.Handler(server.HandleWS))
	// err := http.ListenAndServeTLS(":443", "cert.pem", "key.pem", nil)
	err := http.ListenAndServe(":1337", nil)
	if err != nil {
		log.Fatal("Listen and Server ", err)
	}
}
