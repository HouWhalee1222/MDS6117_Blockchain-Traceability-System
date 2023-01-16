package main

import (
	"fmt"
	"time"
)

func main() {
	timeStr := time.Now().Format("2006-01-02 15:04:05")
    timeStr += "\nI am whale"
	fmt.Println(timeStr)
}