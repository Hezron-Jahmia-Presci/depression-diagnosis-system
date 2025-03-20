package routes

import (
	"depression-diagnosis-system/api/handler"
	"depression-diagnosis-system/api/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine) {
	psychHandler := handler.NewPsychiatristHandler()
	patientHandler := handler.NewPatientHandler()
	phq9Handler := handler.NewPhq9Handler()
	sessionHandler := handler.NewSessionHandler()
	diagnosisHandler := handler.NewDiagnosisHandler()
	sessionSummaryHandler := handler.NesSessionSummaryHandler()

	// Public Routes (Psychiatrists)
	psychRoutes := router.Group("/psych")
	{
		psychRoutes.POST("/register", psychHandler.Register)
		psychRoutes.POST("/login", psychHandler.Login)
		psychRoutes.POST("/logout", psychHandler.Logout) 
	}
	psychRoutes.Use((middleware.AuthMiddleware()))
	{
		psychRoutes.GET("/details", psychHandler.GetPsychiatristDetails)  
		psychRoutes.PUT("/update", psychHandler.UpdatePsychiatrist)  
	}

	// Patient Routes (Protected)
	patientRoutes := router.Group("/patients")
	patientRoutes.Use(middleware.AuthMiddleware())
	{
		patientRoutes.GET("/psych", patientHandler.GetPatientsByPsychiatrist)
		patientRoutes.GET("/all", patientHandler.GetAllPatients)
		patientRoutes.POST("/register", patientHandler.RegisterPatient)
		patientRoutes.GET("/details/:id", patientHandler.GetPateintDetailsByPsychiatirst)
		patientRoutes.GET("/details", patientHandler.GetPatientDetailsByID)
		patientRoutes.PUT("/update", patientHandler.UpdatePatient)

	}

	// Session Routes (Protected)
	sessionRoutes := router.Group("/sessions")
	sessionRoutes.Use(middleware.AuthMiddleware())
	{
		sessionRoutes.POST("/create", sessionHandler.CreateSession)
		sessionRoutes.POST("/follow-up", sessionHandler.CreateFollowUpSession)
		sessionRoutes.PUT("/status", sessionHandler.UpdateSessionStatus)
		sessionRoutes.GET("/psych", sessionHandler.GetSessionsByPsychiatrist)
		sessionRoutes.GET("/all", sessionHandler.GetAllSessions)
		sessionRoutes.GET("/:id", sessionHandler.GetSessionByID)
	}

	// PHQ-9 Question Routes (Protected)
	phq9Routes := router.Group("/phq9")
	phq9Routes.Use(middleware.AuthMiddleware())
	{
		
		phq9Routes.POST("/create", phq9Handler.CreateQuestion)
		phq9Routes.GET("/questions", phq9Handler.GetAllQuestions)
		phq9Routes.GET("/question/:id", phq9Handler.GetQuestionByID)
		
		phq9Routes.POST("/record/:id", phq9Handler.RecordResponsesForSession)
		phq9Routes.GET("/response/:id", phq9Handler.GetResponsesForSession)
	}

	//Diagnosis routes (Protected)
	diagnosisRoutes := router.Group("/diagnosis")
	diagnosisRoutes.Use(middleware.AuthMiddleware())
	{
		diagnosisRoutes.POST("/create/:id", diagnosisHandler.CreateDiagnosis)
		diagnosisRoutes.GET("/session/:id", diagnosisHandler.GetDiagnosisBySessionID)
		
	}

	//session summary routes (Protected)
	sessionSummaryRoutes := router.Group("/session/summary")
	sessionSummaryRoutes.Use(middleware.AuthMiddleware())
	{
		sessionSummaryRoutes.POST("/create/:id", sessionSummaryHandler.CreateSummaryForSession)
		sessionSummaryRoutes.GET("/:id", sessionSummaryHandler.GetSummaryForSession)
	}
}
