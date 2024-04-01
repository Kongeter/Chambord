package lobby

import (
	"encoding/json"
	"fmt"

	"github.com/Kongeter/Chambord/enums"
)

type User struct {
	Channel chan<- []byte
	Name    string
}

func NewUser(ch chan<- []byte, name string) *User {
	return &User{
		Channel: ch,
		Name:    name,
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
	l.Users[key] = u
	return key
}
func (l *Lobby) DisconnectUser(id int) bool {
	delete(l.Users, id)
	if len(l.Users) <= 0 {
		return true
	}
	if l.Host == id {
		for key := range l.Users {
			l.Host = key
			break
		}
	}
	l.BroadcastLobbyInfo()
	return false

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
		u.Channel <- b
	}
}

func (l *Lobby) BroadcastExcludeSelf(b []byte, id int) {
	for i, u := range l.Users {
		if i != id {
			u.Channel <- b
		}

	}
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

func (l *Lobby) BroadcastLobbyInfo() {
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
		Message: enums.Lobby,
		Id:      l.Id,
		Users:   users,
		Host:    l.Host,
	}
	data, err := json.Marshal(lobbyData)
	if err != nil {
		fmt.Printf("oof")
	} else {
		go l.Broadcast(data)
	}

}
