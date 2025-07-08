package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database/model"
)

type MessageHandler struct {
	MessageController interfaces.MessageInterface
}

func NewMessageHandler() *MessageHandler {
	return &MessageHandler{
		MessageController: controller.NewMessageController(),
	}
}

func (mh *MessageHandler) SendMessage(c *gin.Context) {
	var msg model.Message
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}
	msg.Timestamp = time.Now()

	saved, err := mh.MessageController.SendMessage(&msg)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to send message: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Message sent successfully",
		"data":    saved,
	})
}

func (mh *MessageHandler) GetMessagesBetween(c *gin.Context) {
	var params struct {
		SenderID   uint `form:"sender_id" binding:"required"`
		ReceiverID uint `form:"receiver_id" binding:"required"`
	}

	if err := c.ShouldBindQuery(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Missing sender/receiver IDs"})
		return
	}

	messages, err := mh.MessageController.GetMessagesBetween(params.SenderID, params.ReceiverID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Could not retrieve messages: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

func (mh *MessageHandler) GetInbox(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{"message": "User ID not found in context"})
		return
	}

	messages, err := mh.MessageController.GetInboxForUser(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Could not load inbox: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"inbox": messages})
}
