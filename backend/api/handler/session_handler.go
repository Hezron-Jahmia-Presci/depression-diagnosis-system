package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database/model"
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
	var req struct {
		Date      string `json:"date" binding:"required"`
		PatientID uint   `json:"patientID" binding:"required"`
	}
	

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	date, err := time.Parse(time.RFC3339, req.Date)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid date format",
		})
		return
	}

	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Unauthorized access",
		})
		return
	}

	session := &model.Session{
		PsychiatristID: psychID.(uint),
		PatientID:      req.PatientID,
		Date:           date,
	}
	

	created, err := sh.SessionController.CreateSession(session)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create session: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "Session created successfully",
		"session": gin.H{
			"id":             created.ID,
			"psychiatristId": created.PsychiatristID,
			"patientId":      created.PatientID,
			"date":           created.Date,
			"status":         created.Status,
		},
	})
}

func (sh *SessionHandler) CreateFollowUpSession(c *gin.Context) {
	var req struct {
		OriginalSessionID uint   `json:"originalSessionID" binding:"required"`
		Date              string `json:"date" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	date, err := time.Parse(time.RFC3339, req.Date)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid date format",
		})
		return
	}

	followUp, err := sh.SessionController.CreateFollowUpSession(req.OriginalSessionID, date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create follow-up session: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "Follow-up session created successfully",
		"session": gin.H{
			"id":             followUp.ID,
			"psychiatristId": followUp.PsychiatristID,
			"patientId":      followUp.PatientID,
			"date":           followUp.Date,
			"status":         followUp.Status,
		},
	})
}

func (sh *SessionHandler) UpdateSessionStatus(c *gin.Context) {
	var req struct {
		SessionID uint   `json:"sessionID" binding:"required"`
		Status    string `json:"status" binding:"required,oneof=ongoing completed cancelled"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	err := sh.SessionController.UpdateSessionStatus(req.SessionID, req.Status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to update session status: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"message": "Session status updated successfully",
	})
}

func (sh *SessionHandler) GetAllSessions(c *gin.Context) {
	sessions, err := sh.SessionController.GetAllSessions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve sessions: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   http.StatusOK,
		"sessions": sessions,
	})
}

func (sh *SessionHandler) GetSessionsByPsychiatrist(c *gin.Context) {
	psychID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  http.StatusUnauthorized,
			"message": "Unauthorized access",
		})
		return
	}

	sessions, err := sh.SessionController.GetSessionsByPsychiatrist(psychID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve sessions: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   http.StatusOK,
		"sessions": sessions,
	})
}

func (sh *SessionHandler) GetSessionByID(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	session, err := sh.SessionController.GetSessionByID(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve session: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"session": session,
	})
}
