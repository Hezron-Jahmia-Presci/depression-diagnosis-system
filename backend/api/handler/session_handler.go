package handler

import (
	"net/http"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

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

// Only admins, psychologists, psychiatrists, clinical officers can create sessions
func (sh *SessionHandler) CreateSession(c *gin.Context) {
	ptypeI, exists := c.Get("userPersonnelType")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "Unauthorized"})
		return
	}

	ptype, ok := ptypeI.(string)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to parse personnel type"})
		return
	}

	allowedTypes := map[string]bool{
		"Admin":            true,
		"Psychiatrist":     true,
		"Psychologist":     true,
		"Clinical Officer": true,
	}

	if !allowedTypes[ptype] {
		c.JSON(http.StatusForbidden, gin.H{"message": "Insufficient permissions to create session"})
		return
	}

	var input model.Session
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	createdSession, err := sh.SessionController.CreateSession(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create session: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Session created successfully",
		"session": createdSession,
	})
}


func (sh *SessionHandler) GetSessionByID(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	session, err := sh.SessionController.GetSessionByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Session not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"session": session})
}

func (sh *SessionHandler) GetAllSessions(c *gin.Context) {
	sessions, err := sh.SessionController.GetAllSessions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve sessions: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"sessions": sessions})
}

func (sh *SessionHandler) GetSessionByCode(c *gin.Context) {
	code := c.Param("code")
	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Session code is required"})
		return
	}

	session, err := sh.SessionController.GetSessionByCode(code)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Session not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"session": session})
}

func (sh *SessionHandler) GetSessionsByPatient(c *gin.Context) {
	patientID, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid patient ID"})
		return
	}

	sessions, err := sh.SessionController.GetSessionsByPatient(patientID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to fetch sessions: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"sessions": sessions})
}

func (sh *SessionHandler) GetSessionsByHealthWorker(c *gin.Context) {
	healthworkerID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Admin ID not provided",
		})
		return
	}

	sessions, err := sh.SessionController.GetSessionsByHealthWorker(healthworkerID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to fetch sessions: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"sessions": sessions})
}


func (sh *SessionHandler) UpdateSession(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	var updated model.Session
	if err := c.ShouldBindJSON(&updated); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	session, err := sh.SessionController.UpdateSession(id, &updated)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update session: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Session updated successfully",
		"session": session,
	})
}

func (sh *SessionHandler) DeleteSession(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := sh.SessionController.DeleteSession(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete session: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Session deleted successfully"})
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

func (sh *SessionHandler) SearchSessions(c *gin.Context) {
	// Extract query params
	queryParams := map[string]string{
        "session_code":     c.Query("session_code"),
        "health_worker_id": c.Query("health_worker_id"),
        "patient_id":   	c.Query("patient_id"),
    }

	sessions, err := sh.SessionController.SearchSessions(queryParams)
	if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"message": "Search failed: " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"sessions": sessions})
}
