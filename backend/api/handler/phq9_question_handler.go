package handler

import (
	"net/http"

	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/api/util"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
)

type Phq9QuestionHandler struct {
	Phq9QuestionController interfaces.Phq9QuestionInterface
}

func NewPhq9QuestionHandler() *Phq9QuestionHandler {
	return &Phq9QuestionHandler{
		Phq9QuestionController: controller.NewPhq9QuestionController(),
	}
}

// CreateQuestion adds a new PHQ-9 question (only admin)
func (h *Phq9QuestionHandler) CreateQuestion(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can create PHQ-9 questions"})
		return
	}

	var input model.Phq9Question
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid input: " + err.Error()})
		return
	}

	created, err := h.Phq9QuestionController.CreateQuestion(&input)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create question: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":  "PHQ-9 question created successfully",
		"question": created,
	})
}

// GetAllQuestions returns all PHQ-9 questions (open to authenticated users)
func (h *Phq9QuestionHandler) GetAllQuestions(c *gin.Context) {
	questions, err := h.Phq9QuestionController.GetAllQuestions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to retrieve questions: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"questions": questions,
	})
}

// GetQuestionByID fetches a specific PHQ-9 question by ID
func (h *Phq9QuestionHandler) GetQuestionByID(c *gin.Context) {
	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	question, err := h.Phq9QuestionController.GetQuestionByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"message": "Question not found: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"question": question,
	})
}

// DeleteQuestion removes a PHQ-9 question (only admin)
func (h *Phq9QuestionHandler) DeleteQuestion(c *gin.Context) {
	roleI, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"message": "Unauthorized"})
		return
	}
	role, ok := roleI.(string)
	if !ok || role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"message": "Only admins can delete PHQ-9 questions"})
		return
	}

	id, err := util.GetIDParam(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid ID"})
		return
	}

	if err := h.Phq9QuestionController.DeleteQuestion(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to delete question: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "PHQ-9 question deleted successfully",
	})
}
