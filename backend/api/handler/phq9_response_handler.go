package handler

import (
	"net/http"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
)

type Phq9ResponseHandler struct {
	Phq9ResponseController interfaces.Phq9ResponseInterface
}

func NewPhq9ResponseHandler() *Phq9ResponseHandler {
	return &Phq9ResponseHandler{
		Phq9ResponseController: controller.NewPhq9ResponseController(),
	}
}

// CreateResponse submits a new PHQ-9 response (open to authenticated users)
func (h *Phq9ResponseHandler) CreateResponse(c *gin.Context) {
	sessionID, err := util.GetIDParam(c)
	
	var input []model.Phq9ResponseStruct
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid response data: " + err.Error(),
		})
		return
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	created, err := h.Phq9ResponseController.CreateResponse(uint(sessionID), input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create PHQ-9 response: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":   "PHQ-9 response recorded successfully",
		"response":  created,
	})
}

// GetResponseBySessionID fetches the response for a specific session (open to authenticated users)
func (h *Phq9ResponseHandler) GetResponseBySessionID(c *gin.Context) {
	sessionID, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid session ID"})
		return
	}

	resp, err := h.Phq9ResponseController.GetResponseBySessionID(sessionID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "PHQ-9 response not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"response": resp,
	})
}

// UpdateResponse modifies a PHQ-9 response (admin or psychiatrist)
func (h *Phq9ResponseHandler) UpdateResponse(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || (role != "admin" && role != "psychiatrist") {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins or psychiatrists can update PHQ-9 responses"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	var input model.Phq9Response
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	updated, err := h.Phq9ResponseController.UpdateResponse(id, &input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update response: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "PHQ-9 response updated successfully",
		"response": updated,
	})
}

// DeleteResponse removes a PHQ-9 response by ID (admin only)
func (h *Phq9ResponseHandler) DeleteResponse(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can delete PHQ-9 responses"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := h.Phq9ResponseController.DeleteResponse(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete response: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "PHQ-9 response deleted successfully",
	})
}
