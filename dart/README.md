# WHU-sb Dart SDK

Official Dart SDK for the WHU-sb (武汉大学课程评价系统) API. Perfect for Flutter apps.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  whu_sb: ^1.0.0
  http: ^1.0.0
  crypto: ^3.0.0
```

## Usage

```dart
import 'package:whu_sb/whu_sb.dart';

void main() async {
  final client = WHUSBClient(
    apiKey: 'your_api_key',
    apiSecret: 'your_api_secret',
    baseUrl: 'https://whu.sb/api/v1',
  );

  // Search for a course
  final results = await client.searchCourses('计算机');
  for (var course in results.items) {
    print('${course.name} (ID: ${course.id})');
  }
}
```

## Features

- Fully async APIs
- JSON serialization/deserialization
- Support for Course, Teacher, Review, Search, and User APIs
- Secure signature generation for authenticated requests

## License

MIT
