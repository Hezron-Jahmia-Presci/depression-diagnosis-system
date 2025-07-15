// model/message.go
package model

import (
	"time"

	"gorm.io/gorm"
)

type Message struct {
	gorm.Model
	SenderID     uint         `json:"sender_id"`                       // FK to HealthWorker
	Sender       HealthWorker `gorm:"foreignKey:SenderID" json:"sender"`
	ReceiverID   uint         `json:"receiver_id"`                     // FK to HealthWorker
	Receiver     HealthWorker `gorm:"foreignKey:ReceiverID" json:"receiver"`
	Message      string       `gorm:"type:text;not null" json:"message"`
	Timestamp    time.Time    `gorm:"autoCreateTime" json:"timestamp"` // when message was sent
}
