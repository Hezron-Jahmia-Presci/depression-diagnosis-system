package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database/model"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type DiagnosisHandler struct {
	DiagnosisController interfaces.DiagnosisInterface
}

func NewDiagnosisHandler() *DiagnosisHandler {
	return &DiagnosisHandler{
		DiagnosisController: controller.NewDiagnosisController(),
	}
}

// POST /diagnosis/:id
func (dh *DiagnosisHandler) CreateDiagnosis(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || sessionID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	diagnosis := &model.Diagnosis{
		SessionID: uint(sessionID),
	}

	createdDiagnosis, err := dh.DiagnosisController.CreateDiagnosis(diagnosis)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create diagnosis: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":    http.StatusCreated,
		"message":   "Diagnosis created successfully",
		"diagnosis": createdDiagnosis,
	})
}

// GET /diagnosis/:id
func (dh *DiagnosisHandler) GetDiagnosisBySessionID(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || sessionID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	diagnosis, err := dh.DiagnosisController.GetDiagnosisBySessionID(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve diagnosis: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":    http.StatusOK,
		"diagnosis": diagnosis,
	})
}
