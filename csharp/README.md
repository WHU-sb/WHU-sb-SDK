# WHU-sb C# SDK

Official C# SDK for the WHU-sb (武汉大学课程评价系统) API. Perfect for .NET development.

## Requirements

- .NET Standard 2.0+
- `Newtonsoft.Json` for serialization
- `System.Net.Http` for requests

## Installation

```bash
dotnet add package Newtonsoft.Json
```

## Usage

```csharp
using WHUSBSDK;

var client = new WHUSBClient("your_api_key", "your_api_secret", "https://api.whu.sb/api/v1");

// Search for a course
var results = await client.SearchCoursesAsync("计算机");
foreach (var course in results.Items)
{
    Console.WriteLine($"{course.Name} (ID: {course.Id})");
}
```

## Features

- Fully async-await support
- Strongly-typed models
- Support for Courses, Teachers, Reviews, and User Profile
- Built-in signature generation

## License

MIT
