package handler

import (
	"net/http"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
)

type MedicationHistoryHandler struct {
	MedicationHistoryController interfaces.MedicationHistoryInterface
}

func NewMedicationHistoryHandler() *MedicationHistoryHandler {
	return &MedicationHistoryHandler{
		MedicationHistoryController: controller.NewMedicationHistoryController(),
	}
}

// CreateMedicationHistory creates a new medication history record
func (mh *MedicationHistoryHandler) CreateMedicationHistory(c *gin.Context) {
	var input model.MedicationHistory
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	created, err := mh.MedicationHistoryController.CreateMedicationHistory(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create medication history: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":           "Medication history created successfully",
		"medication_history": created,
	})
}

// GetMedicationHistoryByID retrieves medication history by ID
func (mh *MedicationHistoryHandler) GetMedicationHistoryByID(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	medHist, err := mh.MedicationHistoryController.GetMedicationHistoryByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Medication history not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"medication_history": medHist})
}

// GetMedicationHistoriesByPatient gets all medication histories for a patient
func (mh *MedicationHistoryHandler) GetMedicationHistoriesByPatient(c *gin.Context) {
	patientID, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid patient ID"})
		return
	}

	medHists, err := mh.MedicationHistoryController.GetMedicationHistoriesByPatient(patientID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve medication histories: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"medication_histories": medHists})
}

// UpdateMedicationHistory updates an existing medication history record
func (mh *MedicationHistoryHandler) UpdateMedicationHistory(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	var updated model.MedicationHistory
	if err := c.ShouldBindJSON(&updated); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	medHist, err := mh.MedicationHistoryController.UpdateMedicationHistory(id, &updated)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update medication history: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":            "Medication history updated successfully",
		"medication_history": medHist,
	})
}

// DeleteMedicationHistory deletes a medication history record
func (mh *MedicationHistoryHandler) DeleteMedicationHistory(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := mh.MedicationHistoryController.DeleteMedicationHistory(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete medication history: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Medication history deleted successfully"})
}

// GetAllMedicationHistories returns all medication histories
func (mh *MedicationHistoryHandler) GetAllMedicationHistories(c *gin.Context) {
	medHists, err := mh.MedicationHistoryController.GetAllMedicationHistories()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve medication histories: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"medication_histories": medHists})
}

// SearchMedicationHistories handles search queries for medication histories
func (mh *MedicationHistoryHandler) SearchMedicationHistories(c *gin.Context) {
	queryParams := map[string]string{
		"patient_id":          c.Query("patient_id"),
		"prescribing_doctor_id": c.Query("prescribing_doctor_id"),
		"health_center":       c.Query("health_center"),
		"external_doctor_name": c.Query("external_doctor_name"),
	}

	medHists, err := mh.MedicationHistoryController.SearchMedicationHistories(queryParams)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to search medication histories: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"medication_histories": medHists})
}
