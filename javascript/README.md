# WHU-sb JavaScript/TypeScript SDK

Official JavaScript/TypeScript SDK for the WHU-sb (武汉大学课程评价系统) API.

## Installation

```bash
npm install @whu-sb/sdk
```

## Usage

```typescript
import { WHUSBClient } from '@whu-sb/sdk';

const client = new WHUSBClient({
  apiKey: 'your_api_key',
  apiSecret: 'your_api_secret',
  baseUrl: 'https://api.whu.sb/api/v1'
});

// Search for a course
async function main() {
  try {
    const results = await client.searchCourses('计算机');
    results.items.forEach(course => {
      console.log(`${course.name} (ID: ${course.id})`);
    });
  } catch (error) {
    console.error('API Error:', error.message);
  }
}

main();
```

## Features

- **Courses**: Search, List, Get by UID/ID, Get teachers, Get reviews
- **Teachers**: Search, List, Get by UID/ID
- **Reviews**: Submit, Search
- **Search**: Advanced and Simple search
- **Types**: High-quality TypeScript definitions

## License

MIT
