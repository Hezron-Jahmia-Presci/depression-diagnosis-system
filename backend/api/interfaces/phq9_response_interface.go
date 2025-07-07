package interfaces

import "depression-diagnosis-system/database/model"

type Phq9ResponseInterface interface {
	CreateResponse(sessionID uint, resp []model.Phq9ResponseStruct) (*model.Phq9Response, error)
	GetResponseBySessionID(sessionID uint) ([]model.Phq9ResponseStruct, error)
	UpdateResponse(id uint, updated *model.Phq9Response) (*model.Phq9Response, error)
	DeleteResponse(id uint) error
}
