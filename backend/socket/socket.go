package socket

import (
	"encoding/json"
	"fmt"
	"io"
	"strconv"

	"github.com/Kongeter/Chambord/lobby"
	"golang.org/x/net/websocket"
)

const (
	Create = iota
	Join
	Message
	Id
	Lobby
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
	Name string
}
type JoinData struct {
	LobbyId string
	Name    string
}
type YouAre struct {
	Message int
	Id      int
}
type UserData struct {
	Id   int
	Name string
}
type LobbyData struct {
	Message int
	Id      string
	Users   []UserData
	Host    int
}

func (s *Server) HandleWS(ws *websocket.Conn) {
	fmt.Println("new incoming connection from client:", ws.RemoteAddr())
	ws.Write([]byte("start"))
	// s.conns[ws] = true

	s.readLoop(ws)
}

func (s *Server) readLoop(ws *websocket.Conn) {
	myId := -1
	var l *lobby.Lobby
	buf := make([]byte, 1024)
	for {
		n, err := ws.Read(buf)
		if err != nil {
			if err == io.EOF {
				break
			}
			fmt.Println("read error: ", err)
			continue
		}

		msg := buf[:n]

		//try create
		t, _ := strconv.Atoi(string(msg[:1]))

		switch t {
		case Create:
			l, _, myId = s.createLobby(ws)
			sendUserInfo(ws, myId)
			l.SetHost(myId)
			broadcastLobbyInfo(l)
			fmt.Println("lobby created")

		case Join:
			err, l, _, myId = s.joinLobby(ws, msg[1:])
			if err != nil {
				fmt.Println("error: ", err)
			} else {
				fmt.Println("joined lobby")
				sendUserInfo(ws, myId)
				broadcastLobbyInfo(l)
			}
		case Message:
			if l != nil {
				go l.BroadcastExcludeSelf(msg[1:], myId)
			}

		}

	}
}

func sendUserInfo(ws *websocket.Conn, id int) {
	userData := YouAre{
		Message: Id,
		Id:      id,
	}
	data, err := json.Marshal(userData)
	if err != nil {
		fmt.Printf("oof")
	} else {
		ws.Write(data)
	}

}

func broadcastLobbyInfo(l *lobby.Lobby) {
	users := make([]UserData, len(l.Users))
	index := 0
	for i, u := range l.Users {
		users[index] = UserData{
			Id:   i,
			Name: u.Name,
		}
		index++
	}
	lobbyData := LobbyData{
		Message: Lobby,
		Id:      l.Id,
		Users:   users,
		Host:    l.Host,
	}
	data, err := json.Marshal(lobbyData)
	if err != nil {
		fmt.Printf("oof")
	} else {
		l.Broadcast(data)
	}

}

func (s *Server) createLobby(ws *websocket.Conn) (*lobby.Lobby, *lobby.User, int) {
	u := lobby.NewUser(ws, "Ben")
	l := lobby.NewLobby("test")
	id := l.ConnectUser(u)
	s.lobbies["test"] = l
	fmt.Printf("lobby %s created", "test")
	return l, u, id
}

func (s *Server) joinLobby(ws *websocket.Conn, b []byte) (error, *lobby.Lobby, *lobby.User, int) {
	var data JoinData
	fmt.Println(string(b))
	err := json.Unmarshal(b, &data)
	fmt.Println(data.LobbyId)
	if err != nil {
		return err, nil, nil, 0
	}
	l, ok := s.lobbies[data.LobbyId]
	if ok {
		u := lobby.NewUser(ws, data.Name)
		id := l.ConnectUser(u)
		return nil, l, u, id
	}
	fmt.Println(data.LobbyId)
	return fmt.Errorf("lobby %s not found", data.LobbyId), nil, nil, 0

}
