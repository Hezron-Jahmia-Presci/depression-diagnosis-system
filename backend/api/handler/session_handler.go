package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type SessionHandler struct {
	SessionController interfaces.SessionInterface
}

func NewSessionHandler() *SessionHandler {
	return &SessionHandler{
		SessionController: controller.NewSessionController(),
	}
}

func (sh *SessionHandler) CreateSession(c *gin.Context) {
	var request struct {
		Date string `json:"date" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

	date, err := time.Parse(time.RFC3339, request.Date)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: invalid date format",
		})
		return
	}

	patientID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, util.ResponseStructure{
			Status:  http.StatusUnauthorized,
			Message: "error: unauthorized",
		})
		return
	}

	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, util.ResponseStructure{
			Status:  http.StatusUnauthorized,
			Message: "error: unauthorized",
		})
		return
	}

	createdSession, err := sh.SessionController.CreateSession(
		psychID.(uint), patientID.(uint), date,
	)
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
			"PsychiatristID": createdSession.PsychiatristID,
			"PatientID":      createdSession.PatientID,
			"Date":           createdSession.Date,
		},
	})
}


func (sh *SessionHandler) CreateFollowUpSession(c *gin.Context) {
	var request struct {
		OriginalSessionID string `json:"originalSessionID" binding:"required"`
		Date              string `json:"date" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

	originalSessionID, err := strconv.Atoi(request.OriginalSessionID)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: invalid original session ID format",
		})
		return
	}

	date, err := time.Parse(time.RFC3339, request.Date)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: invalid date format",
		})
		return
	}

	followUpSession, err := sh.SessionController.CreateFollowUpSession(uint(originalSessionID), date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Follow-up session created successfully",
		"session": gin.H{
			"PsychiatristID": followUpSession.PsychiatristID,
			"PatientID":      followUpSession.PatientID,
			"Date":           followUpSession.Date,
			"Status":         followUpSession.Status,
		},
	})
}

func (sh *SessionHandler) UpdateSessionStatus(c *gin.Context) {
	var request struct {
		SessionID uint `json:"sessionID" binding:"required"`
		Status    string `json:"status" binding:"required,oneof=ongoing completed cancelled"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}


	err := sh.SessionController.UpdateSessionStatus(request.SessionID, request.Status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Session status updated successfully",
	})
}

func (sh *SessionHandler) GetSessionsByPsychiatrist(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, util.ResponseStructure{
			Status:  http.StatusUnauthorized,
			Message: "error: unauthorized",
		})
		return
	}

	sessions, err := sh.SessionController.GetSessionsByPsychiatrist(psychID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve sessions",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"sessions": sessions})
}

func (sh *SessionHandler) GetAllSessions(c *gin.Context) {
	sessions, err := sh.SessionController.GetAllSessions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve sessions",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"sessions": sessions})
}

func (sh *SessionHandler) GetSessionByID(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	session, err := sh.SessionController.GetSessionByID(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve session",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"session": session})
}
