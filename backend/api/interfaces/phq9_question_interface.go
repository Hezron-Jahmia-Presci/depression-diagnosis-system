package interfaces

import "depression-diagnosis-system/database/model"

type Phq9QuestionInterface interface {
	CreateQuestion(q *model.Phq9Question) (*model.Phq9Question, error)
	GetAllQuestions() ([]model.Phq9Question, error)
	GetQuestionByID(id uint) (*model.Phq9Question, error)
	DeleteQuestion(id uint) error
}
