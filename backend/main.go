package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/Kongeter/Chambord/socket"
)

func main() {
	fmt.Println("started")
	server := socket.NewServer()
	http.Handle("/ws", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Call the server's HandleWs method with the captured server instance
		server.HandleWs(w, r)
	}))
	// err := http.ListenAndServeTLS(":443", "cert.pem", "key.pem", nil)
	err := http.ListenAndServe(":1337", nil)
	if err != nil {
		log.Fatal("Listen and Server ", err)
	}
}
