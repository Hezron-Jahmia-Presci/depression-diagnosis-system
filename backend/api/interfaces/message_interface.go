package interfaces

import "depression-diagnosis-system/database/model"

type MessageInterface interface {
	SendMessage(msg *model.Message) (*model.Message, error)
	GetMessagesBetween(senderID, receiverID uint) ([]model.Message, error)
	GetInboxForUser(userID uint) ([]model.Message, error)
}
