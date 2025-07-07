package middleware

import (
	"errors"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"depression-diagnosis-system/database"
	"depression-diagnosis-system/database/model"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
)

var jwtSecret = []byte(os.Getenv("JWT_SECRET"))
var tokenBlacklist = make(map[string]bool)
var mu sync.Mutex

type Claims struct {
	ID    uint   `json:"userID"`
	Email string `json:"email"`
	jwt.StandardClaims
}

func GenerateToken(id uint, email string) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		ID:    id,
		Email: email,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"status":  http.StatusUnauthorized,
				"message": "Authorization header required.",
			})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if IsTokenBlacklisted(tokenString) {
			c.JSON(http.StatusUnauthorized, gin.H{
				"status":  http.StatusUnauthorized,
				"message": "Token is blacklisted.",
			})
			c.Abort()
			return
		}

		claims := &Claims{}
		token, err := jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
			return jwtSecret, nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{
				"status":  http.StatusUnauthorized,
				"message": "Invalid or expired token.",
			})
			c.Abort()
			return
		}

		// Lookup the user (HealthWorker) and preload PersonnelType
		var user model.HealthWorker
		if err := database.DB.Preload("PersonnelType").First(&user, claims.ID).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"status":  http.StatusUnauthorized,
				"message": "User not found.",
			})
			c.Abort()
			return
		}

		// Set authenticated user info into Gin context
		c.Set("userID", user.ID)
		c.Set("username", user.Email)
		c.Set("userPersonnelType", user.PersonnelType.Name) // e.g. "admin", "psychiatrist", etc.

		c.Next()
	}
}

func InvalidateToken(token string) error {
	mu.Lock()
	defer mu.Unlock()

	if token == "" {
		return errors.New("invalid token")
	}
	tokenBlacklist[token] = true
	return nil
}

func IsTokenBlacklisted(token string) bool {
	mu.Lock()
	defer mu.Unlock()
	return tokenBlacklist[token]
}
