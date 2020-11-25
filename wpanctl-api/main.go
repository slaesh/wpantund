package main

import (
	"fmt"
	"net/http"
	"os/exec"
	"strings"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

// CommandToExecute ...
type CommandToExecute struct {
	Command   string `json:"command"`
	Arguments string `json:"arguments"`
}

func main() {

	fmt.Println()

	// Echo instance
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Route => handler
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!\n")
	})

	e.GET("/wpanctl/status", func(c echo.Context) error {
		cmd := exec.Command("wpanctl", "status")
		output, _ := cmd.CombinedOutput()

		//fmt.Println(string(output))

		return c.String(http.StatusOK, string(output))
	})

	e.POST("/wpanctl", func(c echo.Context) error {

		cmdToExec := new(CommandToExecute)
		if err := c.Bind(&cmdToExec); err != nil {
			return c.String(http.StatusUnprocessableEntity, err.Error())
		}

		if len(cmdToExec.Arguments) <= 0 {
			return c.String(http.StatusUnprocessableEntity, "no cmd found..")
		}

		//if !strings.HasPrefix(cmd.Command, "wpanctl ") {
		//	return c.String(http.StatusUnprocessableEntity, "only 'wpanctl' is allowed!!")
		//}

		//cmdToExec.Command = "wpanctl"
		cmdResult := exec.Command(cmdToExec.Command, strings.Split(cmdToExec.Arguments, " ")...)
		output, _ := cmdResult.CombinedOutput()

		fmt.Println(string(output))

		return c.String(http.StatusOK, string(output))
	})

	// Start server
	e.Logger.Fatal(e.Start(":7172"))
}
