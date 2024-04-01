package lobby

import (
	"fmt"

	"golang.org/x/net/websocket"
)

type User struct {
	Connection *websocket.Conn
	Name       string
}

func NewUser(conn *websocket.Conn, name string) *User {
	return &User{
		Connection: conn,
		Name:       name,
	}
}
func (u *User) ChangeName(name string) {
	u.Name = name
}

type Lobby struct {
	Id    string
	Users map[int]*User
	Host  int
}

func NewLobby(id string) *Lobby {
	return &Lobby{
		Id:    id,
		Users: make(map[int]*User),
		Host:  -1,
	}
}

func (l *Lobby) ConnectUser(u *User) int {
	key := l.getUniqueId()
	fmt.Println(key)
	l.Users[key] = u
	return key
}

func (l *Lobby) SetHost(id int) {
	l.Host = id
}

func (l *Lobby) getUniqueId() int {
	h := -0
	for key := range l.Users {
		if key > h {
			h = key
		}
	}
	return h + 1
}

func (l *Lobby) Broadcast(b []byte) {
	for _, u := range l.Users {
		u.Connection.Write(b)
	}
}

func (l *Lobby) BroadcastExcludeSelf(b []byte, id int) {
	for i, u := range l.Users {
		if i != id {
			u.Connection.Write(b)
		}

	}
}
