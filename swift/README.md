# WHU-sb Swift SDK

Official Swift SDK for the WHU-sb (武汉大学课程评价系统) API.

## Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.5+
- Foundation (URLSession)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/WHUSBSDK-Swift.git", from: "1.0.0")
]
```

## Usage

```swift
import WHUSBSDK

let client = WHUSBClient(
    apiKey: "your_api_key",
    apiSecret: "your_api_secret",
    baseUrl: "https://api.whu.sb/api/v1"
)

// Search for a course
Task {
    do {
        let results = try await client.searchCourses(query: "计算机")
        for course in results.items {
            print("\(course.name) (ID: \(course.id))")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

## Features

- Fully async/await support
- Strongly typed Codable models
- Includes Course, Teacher, Review, Search, and User APIs
- Automatic signature generation

## License

MIT
