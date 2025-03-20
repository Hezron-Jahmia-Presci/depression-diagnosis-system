package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
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

func (dh *DiagnosisHandler) CreateDiagnosis(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	diagnosis, err := dh.DiagnosisController.CreateDiagnosis(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not create diagnosis",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"diagnosis": diagnosis})
}

func (dh *DiagnosisHandler) GetDiagnosisBySessionID(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	sessionDiagnosis, err := dh.DiagnosisController.GetDiagnosisBySessionID(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: could not retrieve diagnosis",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"diagnosis": sessionDiagnosis})
}

