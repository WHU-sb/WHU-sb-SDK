# WHU-sb Java SDK

Official Java SDK for the WHU-sb (武汉大学课程评价系统) API.

## Requirements

- Java 11 or higher
- Context-aware HTTP client (like OkHttp or Java's HttpClient)

## Installation

Add the following dependency to your `pom.xml`:

```xml
<dependency>
    <groupId>sb.whu</groupId>
    <artifactId>whu-sb-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

## Usage

```java
import sb.whu.WHUSBClient;
import sb.whu.models.Course;

public class Main {
    public static void main(String[] args) {
        WHUSBClient client = new WHUSBClient("your_api_key", "your_api_secret");
        
        // Search for a course
        var results = client.searchCourses("计算机", 1, 10);
        for (Course course : results.getItems()) {
            System.out.println(course.getName());
        }
    }
}
```

## Features

- Full coverage of Course, Teacher, and Review APIs
- Search (Simple/Advanced/QueryBuilder)
- User profile and activity
- External HAM data access
- Secure signature generation

## License

MIT
