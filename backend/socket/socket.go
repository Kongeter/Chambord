package socket

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"strconv"

	"github.com/Kongeter/Chambord/enums"
	"github.com/Kongeter/Chambord/lobby"
	"github.com/gorilla/websocket"
)

type Server struct {
	lobbies map[string]*lobby.Lobby
}

func NewServer() *Server {
	return &Server{
		lobbies: make(map[string]*lobby.Lobby),
	}
}

type CreateData struct {
	LobbyId string
	Name    string
}
type JoinData struct {
	LobbyId string
	Name    string
}
type YouAre struct {
	Message int
	Id      int
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func (s *Server) HandleWs(w http.ResponseWriter, r *http.Request) {

	upgrader.CheckOrigin = func(r *http.Request) bool { return true }

	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
	}
	log.Println("connected")
	s.readLoop(ws)

}

// func (s *Server) HandleWS(ws *websocket.Conn) {
// 	fmt.Println("new incoming connection from client:", ws.RemoteAddr())
// 	ws.Write([]byte("start"))
// 	// s.conns[ws] = true

//		s.readLoop(ws)
//	}
func Writer(ch <-chan []byte, ws *websocket.Conn) {
	for {
		val, ok := <-ch
		if !ok {
			log.Println("closed channel")
			return
		}
		ws.WriteMessage(websocket.BinaryMessage, val)

	}
}

func (s *Server) readLoop(ws *websocket.Conn) {
	myId := -1
	var l *lobby.Lobby
	ch := make(chan []byte)
	go Writer(ch, ws)
	for {
		_, msg, err := ws.ReadMessage()

		//n, err := ws.Read(buf)
		if err != nil {
			log.Printf("error: %v", err)
			if l != nil {
				s.disconnect(l, myId)
			}

			break
		}

		//try create
		t, _ := strconv.Atoi(string(msg[:1]))

		switch t {
		case enums.Create:
			err, l, _, myId = s.createLobby(ch, msg[1:])
			if err != nil {
				fmt.Println("error: ", err)
			} else {
				sendUserInfo(ch, myId)
				l.SetHost(myId)
				l.BroadcastLobbyInfo()
				fmt.Println("lobby created")

			}

		case enums.Join:
			err, l, _, myId = s.joinLobby(ch, msg[1:])
			if err != nil {
				fmt.Println("error: ", err)
			} else {
				fmt.Println("joined lobby")
				sendUserInfo(ch, myId)
				l.BroadcastLobbyInfo()
			}
		case enums.Message:
			if l != nil {
				go l.BroadcastExcludeSelf(msg[1:], myId)
			}

		}

	}
}

func sendUserInfo(ch chan<- []byte, id int) {
	userData := YouAre{
		Message: enums.Id,
		Id:      id,
	}
	data, err := json.Marshal(userData)
	if err != nil {
		fmt.Printf("oof")
	} else {
		ch <- data
	}

}

const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func getLobbyId() string {
	b := make([]byte, 6)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)

}

func (s *Server) createLobby(ch chan<- []byte, b []byte) (error, *lobby.Lobby, *lobby.User, int) {
	var data CreateData
	err := json.Unmarshal(b, &data)
	if err != nil {
		return err, nil, nil, 0
	}
	u := lobby.NewUser(ch, data.Name)
	var l *lobby.Lobby
	var lobbyId string
	if data.LobbyId != "" {
		lobbyId = data.LobbyId
	} else {
		lobbyId = getLobbyId()
	}
	l = lobby.NewLobby(lobbyId)

	id := l.ConnectUser(u)
	s.lobbies[lobbyId] = l
	return nil, l, u, id
}

func (s *Server) joinLobby(ch chan<- []byte, b []byte) (error, *lobby.Lobby, *lobby.User, int) {
	var data JoinData
	err := json.Unmarshal(b, &data)
	if err != nil {
		return err, nil, nil, 0
	}
	l, ok := s.lobbies[data.LobbyId]
	if ok {
		u := lobby.NewUser(ch, data.Name)
		id := l.ConnectUser(u)
		return nil, l, u, id
	}
	fmt.Println(data.LobbyId)
	return fmt.Errorf("lobby %s not found", data.LobbyId), nil, nil, 0

}

func (s *Server) disconnect(l *lobby.Lobby, userId int) {
	lobbyEmpty := l.DisconnectUser(userId)
	if lobbyEmpty {
		log.Println("lobby closed")
		delete(s.lobbies, l.Id)
	}

}
