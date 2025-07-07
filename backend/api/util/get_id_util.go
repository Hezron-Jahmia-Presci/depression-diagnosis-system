package util

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetIDParam(c *gin.Context) (uint, error) {
	idStr := c.Param("id")
	id64, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		return 0, err
	}
	return uint(id64), nil
}
