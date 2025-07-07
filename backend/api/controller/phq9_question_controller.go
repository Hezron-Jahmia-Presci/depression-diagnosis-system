package controller

import (
	"depression-diagnosis-system/api/interfaces"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"
	"errors"
)

type Phq9QuestionController struct{}

func NewPhq9QuestionController() interfaces.Phq9QuestionInterface {
	return &Phq9QuestionController{}
}

func (c *Phq9QuestionController) CreateQuestion(q *model.Phq9Question) (*model.Phq9Question, error) {
	if q.Question == "" {
		return nil, errors.New("question cannot be empty")
	}
	if err := database.DB.Create(q).Error; err != nil {
		return nil, err
	}
	return q, nil
}

func (c *Phq9QuestionController) GetAllQuestions() ([]model.Phq9Question, error) {
	var questions []model.Phq9Question
	if err := database.DB.Find(&questions).Error; err != nil {
		return nil, err
	}
	return questions, nil
}

func (c *Phq9QuestionController) GetQuestionByID(id uint) (*model.Phq9Question, error) {
	var question model.Phq9Question
	if err := database.DB.First(&question, id).Error; err != nil {
		return nil, err
	}
	return &question, nil
}

func (c *Phq9QuestionController) DeleteQuestion(id uint) error {
	var question model.Phq9Question
	if err := database.DB.First(&question, id).Error; err != nil {
		return err
	}
	return database.DB.Delete(&question).Error
}
