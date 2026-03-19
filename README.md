# WHU-sb API SDK

This directory contains official SDKs for interacting with the WHU-sb (武汉大学课程评价系统) API in various programming languages.

## Supported Languages

- [Python](./python) - Python 3.8+
- [Go](./go) - Go 1.20+
- [JavaScript/TypeScript](./javascript) - Node.js 16+ or Browser
- [Java](./java) - Java 11+
- [Rust](./rust) - Rust 1.56+

## API Documentation

For full API documentation, please refer to the backend's documentation service at `http://your-server-address/api/v1`.

## Authentication

Most API endpoints require authentication.- **Course**: Search, Get by UID/ID, Get teachers, Get reviews
- **Teacher**: Search, Get by UID/ID, Get courses
- **Review**: Search, Get by UID/ID, Submit review
- **Search**: All, Simple, Advanced, QueryBuilder, Hot Searches
- **User**: Profile, Activity, Dashboard, Notifications
- **Translation**: Translate, Status
You can obtain an API key and secret from your user profile page in the application.

```bash
# Example environment variables
WHU_SB_API_KEY=your_api_key
WHU_SB_API_SECRET=your_api_secret
WHU_SB_BASE_URL=https://whu.sb/api/v1
```

## Security

Please do not commit your API keys to version control. Use environment variables or a configuration file.

## License

MIT
