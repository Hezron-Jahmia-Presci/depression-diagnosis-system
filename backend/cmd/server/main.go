package main

import (
	"context"
	"depression-diagnosis-system/api/middleware"
	"depression-diagnosis-system/database"
	"depression-diagnosis-system/routes"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found. Using system environment variables.")
	} else {
		log.Println(".env file loaded successfully")
	}

	// Connect to the database and run migrations
	database.Conn()
	database.DBMigrate()
	database.SeedPHQ9Questions()

	// Set Gin mode based on environment
	mode := os.Getenv("GIN_MODE")
	if mode == "" {
		gin.SetMode(gin.DebugMode) // default
	} else {
		gin.SetMode(mode)
	}

	// Set up Gin router
	router := gin.New()
	router.Use(gin.Logger(), gin.Recovery())
	router.Use(middleware.CORSMiddleware())

	// Register routes
	routes.Routes(router)

	// Get port from environment or fallback
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Create HTTP server
	srv := &http.Server{
		Addr:    fmt.Sprintf(":%s", port),
		Handler: router,
	}

	// Start server in a goroutine
	go func() {
		log.Printf("🚀 Server starting on port %s", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("❌ ListenAndServe failed: %v", err)
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("⚠️ Interrupt received. Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("❌ Server forced to shutdown: %v", err)
		os.Exit(1)
	}

	log.Println("✅ Server exited gracefully")
}
