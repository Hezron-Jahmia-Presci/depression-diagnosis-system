package handler

import (
	"depression-diagnosis-system/api/controller"
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database/model"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type Phq9Handler struct {
	Phq9Controller interfaces.Phq9Interface
}

func NewPhq9Handler() *Phq9Handler {
	return &Phq9Handler{
		Phq9Controller: controller.NewPhq9Controller(),
	}
}

// --- Question Management ---

func (pqh *Phq9Handler) CreateQuestion(c *gin.Context) {
	var question model.Phq9Question
	if err := c.ShouldBindJSON(&question); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid input: " + err.Error(),
		})
		return
	}

	created, err := pqh.Phq9Controller.CreateQuestion(&question)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to create question: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":  http.StatusCreated,
		"message": "PHQ-9 question created successfully",
		"question": created,
	})
}

func (pqh *Phq9Handler) GetQuestionByID(c *gin.Context) {
	questionID, err := strconv.ParseUint(c.Param("questionID"), 10, 32)
	if err != nil || questionID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid question ID",
		})
		return
	}

	question, err := pqh.Phq9Controller.GetQuestionByID(uint(questionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve question: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   http.StatusOK,
		"question": question,
	})
}

func (pqh *Phq9Handler) GetAllQuestions(c *gin.Context) {
	questions, err := pqh.Phq9Controller.GetAllQuestions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve questions: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":    http.StatusOK,
		"questions": questions,
	})
}

// --- Response Management ---

func (pqh *Phq9Handler) RecordResponses(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || sessionID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	var responses []model.Phq9ResponseStruct
	if err := c.ShouldBindJSON(&responses); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid response data: " + err.Error(),
		})
		return
	}

	recorded, err := pqh.Phq9Controller.RecordResponses(uint(sessionID), responses)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to record responses: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":   http.StatusCreated,
		"message":  "PHQ-9 responses recorded successfully",
		"response": recorded,
	})
}

func (pqh *Phq9Handler) GetResponses(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || sessionID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	responses, err := pqh.Phq9Controller.GetResponses(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to fetch responses: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":    http.StatusOK,
		"responses": responses,
	})
}

func (pqh *Phq9Handler) GetResponseSummary(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil || sessionID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  http.StatusBadRequest,
			"message": "Invalid session ID",
		})
		return
	}

	summary, err := pqh.Phq9Controller.GetResponseSummary(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  http.StatusInternalServerError,
			"message": "Failed to retrieve summary: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  http.StatusOK,
		"summary": summary,
	})
}
