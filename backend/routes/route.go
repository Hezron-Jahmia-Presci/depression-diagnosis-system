package routes

import (
	"depression-diagnosis-system/api/handler"
	"depression-diagnosis-system/api/middleware"

	"github.com/gin-gonic/gin"
)

func Routes(router *gin.Engine) {
	adminHandler := handler.NewAdminHandler()
	patientHandler := handler.NewPatientHandler()
	psychHandler := handler.NewPsychiatristHandler()
	phq9Handler := handler.NewPhq9Handler()
	diagnosisHandler := handler.NewDiagnosisHandler()
	sessionHandler := handler.NewSessionHandler()
	summaryHandler := handler.NewSessionSummaryHandler()

	// ------------------- Admin Routes -------------------
	adminRoutes := router.Group("/api/v1/admin")
	{
		adminRoutes.POST("/login", adminHandler.LogInAdmin)
		adminRoutes.POST("/create", adminHandler.CreateAdmin)
		adminRoutes.POST("/logout", middleware.AuthMiddleware(), adminHandler.LogOutAdmin)
		adminRoutes.GET("/", middleware.AuthMiddleware(), adminHandler.GetAdminByID)
		adminRoutes.PUT("/", middleware.AuthMiddleware(), adminHandler.UpdateAdmin)
		adminRoutes.DELETE("/", middleware.AuthMiddleware(), adminHandler.DeleteAdmin)
	}

	// ------------------- Psychiatrist Routes -------------------
	psychRoutes := router.Group("/api/v1/psychiatrists")
	{
		psychRoutes.POST("/login", psychHandler.LogInPsychiatrist)
		psychRoutes.POST("/logout", middleware.AuthMiddleware(), psychHandler.LogOutPsychiatrist)

		psychRoutes.POST("/create", psychHandler.CreatePsychiatrist)
		psychRoutes.GET("/", middleware.AuthMiddleware(), psychHandler.GetAllPsychiatrists)
		psychRoutes.GET("/me", middleware.AuthMiddleware(), psychHandler.GetPsychiatristByID)
		psychRoutes.PUT("/", middleware.AuthMiddleware(), psychHandler.UpdatePsychiatrist)
		psychRoutes.DELETE("/", middleware.AuthMiddleware(), psychHandler.DeletePsychiatrist)
	}

	// ------------------- Patient Routes -------------------
	patientRoutes := router.Group("/api/v1/patients")
	patientRoutes.Use(middleware.AuthMiddleware())
	{
		patientRoutes.POST("/create", patientHandler.CreatePatient)
		patientRoutes.GET("/", patientHandler.GetAllPatients)
		patientRoutes.GET("/mine", patientHandler.GetPatientsByPsychiatrist)
		patientRoutes.GET("/:id", patientHandler.GetPatientByID)
		patientRoutes.GET("/:id/by-psych", patientHandler.GetPatientByPsychiatrist)
		patientRoutes.PUT("/", patientHandler.UpdatePatient)
		patientRoutes.DELETE("/:id", patientHandler.DeletePatient)
	}

	// ------------------- PHQ-9 Routes -------------------
	phqRoutes := router.Group("/api/v1/phq9")
	phqRoutes.Use(middleware.AuthMiddleware())
	{
		// Questions
		phqRoutes.POST("/questions", phq9Handler.CreateQuestion)
		phqRoutes.GET("/questions", phq9Handler.GetAllQuestions)
		phqRoutes.GET("/questions/:questionID", phq9Handler.GetQuestionByID)

		// Responses
		phqRoutes.POST("/responses/:id", phq9Handler.RecordResponses)
		phqRoutes.GET("/responses/:id", phq9Handler.GetResponses)
		phqRoutes.GET("/summary/:id", phq9Handler.GetResponseSummary)
	}

	// ------------------- Diagnosis Routes -------------------
	diagnosisRoutes := router.Group("/api/v1/diagnosis")
	diagnosisRoutes.Use(middleware.AuthMiddleware())
	{
		diagnosisRoutes.POST("/:id", diagnosisHandler.CreateDiagnosis)
		diagnosisRoutes.GET("/:id", diagnosisHandler.GetDiagnosisBySessionID)
	}

	// ------------------- Session Routes -------------------
	sessionRoutes := router.Group("/api/v1/sessions")
	sessionRoutes.Use(middleware.AuthMiddleware())
	{
		sessionRoutes.POST("/create", sessionHandler.CreateSession)
		sessionRoutes.POST("/followup", sessionHandler.CreateFollowUpSession)
		sessionRoutes.PUT("/status", sessionHandler.UpdateSessionStatus)
		sessionRoutes.GET("/", sessionHandler.GetAllSessions)
		sessionRoutes.GET("/mine", sessionHandler.GetSessionsByPsychiatrist)
		sessionRoutes.GET("/:id", sessionHandler.GetSessionByID)
	}

	// ------------------- Session Summary Routes -------------------
	summaryRoutes := router.Group("/api/v1/session-summary")
	summaryRoutes.Use(middleware.AuthMiddleware())
	{
		summaryRoutes.POST("/:id", summaryHandler.CreateSessionSummary)
		summaryRoutes.GET("/:id", summaryHandler.GetSessionSummary)
	}
}
