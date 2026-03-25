# WHU-sb API SDK

This directory contains official SDKs for interacting with the WHU-sb (武汉大学课程评价系统) API in various programming languages.

## Supported Languages

| Language | Platform | Link |
| --- | --- | --- |
| **Python** | Python 3.8+ | [./python](./python) |
| **Go** | Go 1.20+ | [./go](./go) |
| **TypeScript/JS** | Node.js / Browser | [./javascript](./javascript) |
| **Java** | Java 11+ | [./java](./java) |
| **Rust** | Rust 1.56+ | [./rust](./rust) |
| **Swift** | iOS / macOS | [./swift](./swift) |
| **Dart** | Flutter / Dart | [./dart](./dart) |
| **C#** | .NET Standard 2.0+ | [./csharp](./csharp) |
| **Ruby** | Ruby 2.7+ | [./ruby](./ruby) |
| **PHP** | PHP 7.4+ | [./php](./php) |

## API Documentation

For full API documentation, please refer to the backend's documentation service at `http://your-server-address/api/v1`.

## Features

- **Course**: Search, Get by UID/ID, Get teachers, Get reviews, Batch search
- **Teacher**: Search, Get by UID/ID, Get courses
- **Review**: Search, Get by UID/ID, Submit review (with signature)
- **Search**: All, Simple, Advanced, QueryBuilder, Hot Searches
- **User**: Profile, Activity, Dashboard, Notifications, Preferences
- **Translation**: Translate text, Check service status
- **External**: Integration with HAM course statistics

## Authentication

Most API endpoints require authentication. You can obtain an API key and secret from your user profile page in the application.

```bash
# Example environment variables
WHU_SB_API_KEY=your_api_key
WHU_SB_API_SECRET=your_api_secret
WHUSB_API_BASE_URL=https://api.whu.sb/api/v1
```

## Security

Please do not commit your API keys to version control. Use environment variables or a configuration file.

## License

MIT
