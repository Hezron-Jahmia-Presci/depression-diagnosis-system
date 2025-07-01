package interfaces

import "depression-diagnosis-system/database/model"

type Phq9Interface interface {
	// Question management
	CreateQuestion(question *model.Phq9Question) (*model.Phq9Question, error)
	GetQuestionByID(id uint) (*model.Phq9Question, error)
	GetAllQuestions() ([]model.Phq9Question, error)

	// Response management
	RecordResponses(sessionID uint, responses []model.Phq9ResponseStruct) (*model.Phq9Response, error)
	GetResponses(sessionID uint) ([]model.Phq9ResponseStruct, error)
	GetResponseSummary(sessionID uint) (*model.Phq9Response, error)
}
