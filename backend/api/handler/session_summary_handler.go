package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type SessionSummaryHandler struct {
	SessionSummaryController interfaces.SessionSummary
}

func NesSessionSummaryHandler() *SessionSummaryHandler {
	return &SessionSummaryHandler{
		SessionSummaryController: controller.NewSessionSummaryController(),
	}
}

func (ssh *SessionSummaryHandler) CreateSummaryForSession(c *gin.Context) {
	var request struct {
		Notes string `json:"notes" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

		sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	createdSessionSummary, err := ssh.SessionSummaryController.CreateSummaryForSession(uint(sessionID), request.Notes)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	
	c.JSON(http.StatusCreated, gin.H{
		"message": "Session created successfully",
		"session": gin.H{
			"SessionID": createdSessionSummary.SessionID,
			"Notes":     createdSessionSummary.Notes,
		},
	})
}

func (ssh *SessionSummaryHandler) GetSummaryForSession(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	sessionSummary, err := ssh.SessionSummaryController.GetSummaryForSession(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve session",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"sessionSummary": sessionSummary})
}