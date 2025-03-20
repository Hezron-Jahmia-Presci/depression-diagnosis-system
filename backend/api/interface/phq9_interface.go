package interfaces

import "depression-diagnosis-system/database/model"

type Phq9Interface interface {
	// Question Management
	CreateQuestion(question *model.Phq9Question) (*model.Phq9Question, error)
	GetAllQuestions() ([]model.Phq9Question, error)
	GetQuestionByID(id uint) (*model.Phq9Question, error)

	RecordResponsesForSession(sessionID uint, responses []model.Phq9ResponseStruct) (*model.Phq9Response, error)
	GetResponsesBySession(sessionID uint) (*model.Phq9Response, error)
	GetResponsesForSession(sessionID uint) ([]model.Phq9ResponseStruct, error)
}
