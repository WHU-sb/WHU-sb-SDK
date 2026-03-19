# WHU-sb Go SDK

Official Go SDK for the WHU-sb (武汉大学课程评价系统) API.

## Installation

```bash
go get github.com/your-username/whu-sb-sdk-go
```

## Usage

```go
package main

import (
	"fmt"
	"github.com/your-username/whu-sb-sdk-go"
)

func main() {
	// Initialize the client
	client := whusb.NewClient("your_api_key", "your_api_secret", "https://whu.sb/api/v1")

	// Search for a course
	results, err := client.SearchCourses("计算机", 1, 10)
	if err != nil {
		panic(err)
	}

	for _, course := range results.Items {
		fmt.Printf("%s (ID: %d)\n", course.Name, course.ID)
	}

	// Get course detail
	course, err := client.GetCourse("CS101")
	if err == nil {
		fmt.Println(course.Name)
	}
}
```

## Features

- **Course**: List, Search, Suggest, Get by UID/ID, Get teachers, Get reviews
- **Review**: Submit review, Search reviews
- **Teacher**: Search teachers, List all teachers
- **Search**: Advanced and Simple search

## License

MIT
