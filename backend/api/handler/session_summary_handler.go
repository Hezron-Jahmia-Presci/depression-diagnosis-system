package handler

import (
	"net/http"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

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

// CreateSummary creates a session summary (only admin or psychiatrist)
func (ssh *SessionSummaryHandler) CreateSummary(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || (role != "admin" && role != "psychiatrist") {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins or psychiatrists can create session summaries"})
		return
	}

	var input model.SessionSummary
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	createdSummary, err := ssh.SessionSummaryController.CreateSummary(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create session summary: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":         "Session summary created successfully",
		"session_summary": createdSummary,
	})
}

// GetSummaryBySessionID fetches summary by session ID (open to authenticated users)
func (ssh *SessionSummaryHandler) GetSummaryBySessionID(c *gin.Context) {
	sessionID, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid session ID"})
		return
	}

	summary, err := ssh.SessionSummaryController.GetSummaryBySessionID(sessionID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Session summary not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"session_summary": summary,
	})
}

// UpdateSummary updates a session summary (only admin or psychiatrist)
func (ssh *SessionSummaryHandler) UpdateSummary(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || (role != "admin" && role != "psychiatrist") {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins or psychiatrists can update session summaries"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid summary ID"})
		return
	}

	var input model.SessionSummary
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	updatedSummary, err := ssh.SessionSummaryController.UpdateSummary(id, &input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update session summary: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":         "Session summary updated successfully",
		"session_summary": updatedSummary,
	})
}

// DeleteSummary deletes a session summary by ID (only admin)
func (ssh *SessionSummaryHandler) DeleteSummary(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can delete session summaries"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid summary ID"})
		return
	}

	if err := ssh.SessionSummaryController.DeleteSummary(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete session summary: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Session summary deleted successfully",
	})
}
