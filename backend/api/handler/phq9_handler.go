package handler

import (
	"depression-diagnosis-system/api/controller"
	interfaces "depression-diagnosis-system/api/interface"
	"depression-diagnosis-system/api/util"
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

func (pqh *Phq9Handler) CreateQuestion(c *gin.Context) {
	var question model.Phq9Question
	if err := c.ShouldBindJSON(&question); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

	createdQuestion, err := pqh.Phq9Controller.CreateQuestion(&question)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"Phq9Question": createdQuestion})
}

func (pqh *Phq9Handler) GetAllQuestions(c *gin.Context) {
	questions, err := pqh.Phq9Controller.GetAllQuestions()
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"Phq9Questions": questions})
}

func (pqh *Phq9Handler) GetQuestionByID(c *gin.Context) {
	questionID, err := strconv.ParseUint(c.Param("questionID"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid question ID",
		})
		return
	}

	question, err := pqh.Phq9Controller.GetQuestionByID(uint(questionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"Phq9Question": question})
}

func (pqh *Phq9Handler) RecordResponsesForSession(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	var responsesStruct []model.Phq9ResponseStruct
	if err := c.ShouldBindJSON(&responsesStruct); err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "error: " + err.Error(),
		})
		return
	}

	diagnosis, err := pqh.Phq9Controller.RecordResponsesForSession(uint(sessionID), responsesStruct)
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"Phq9Diagnosis": diagnosis})
}

func (pqh *Phq9Handler) GetResponsesForSession(c *gin.Context) {
	sessionID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, util.ResponseStructure{
			Status:  http.StatusBadRequest,
			Message: "Invalid session ID",
		})
		return
	}

	responses, err := pqh.Phq9Controller.GetResponsesForSession(uint(sessionID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, util.ResponseStructure{
			Status:  http.StatusInternalServerError,
			Message: "error: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"Phq9Responses": responses})
}
