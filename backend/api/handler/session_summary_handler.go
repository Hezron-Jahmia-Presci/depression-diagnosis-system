package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database/model"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type SessionSummaryHandler struct {
	SessionSummaryController interfaces.SessionSummaryInterface
}

func NewSessionSummaryHandler() *SessionSummaryHandler {
	return &SessionSummaryHandler{
		SessionSummaryController: controller.NewSessionSummaryController(),
	}
}

func (ssh *SessionSummaryHandler) CreateSessionSummary(c *gin.Context) {
	var req struct {
		Notes string `json:"notes" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	summary := &model.SessionSummary{
		SessionID: uint(sessionID),
		Notes:     req.Notes,
	}

	created, err := ssh.SessionSummaryController.CreateSessionSummary(summary)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create session summary: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "Session summary created successfully",
		"summary": gin.H{
			"sessionID": created.SessionID,
			"notes":     created.Notes,
		},
	})
}

func (ssh *SessionSummaryHandler) GetSessionSummary(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	summary, err := ssh.SessionSummaryController.GetSessionSummaryBySessionID(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve session summary: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"summary": summary,
	})
}
