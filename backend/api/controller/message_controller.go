package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
)

type MessageController struct{}

func NewMessageController() interfaces.MessageInterface {
	return &MessageController{}
}

func (mc *MessageController) SendMessage(msg *model.Message) (*model.Message, error) {
	if err := database.DB.Create(msg).Error; err != nil {
		return nil, err
	}
	return msg, nil
}

func (mc *MessageController) GetMessagesBetween(senderID, receiverID uint) ([]model.Message, error) {
	var messages []model.Message
	err := database.DB.
		Preload("Sender").Preload("Receiver").
		Where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
			senderID, receiverID, receiverID, senderID).
		Order("timestamp ASC").
		Find(&messages).Error
	return messages, err
}

func (mc *MessageController) GetInboxForUser(userID uint) ([]model.Message, error) {
	var messages []model.Message
	err := database.DB.
		Preload("Sender").Preload("Receiver").
		Where("receiver_id = ?", userID).
		Order("timestamp DESC").
		Find(&messages).Error
	return messages, err
}
