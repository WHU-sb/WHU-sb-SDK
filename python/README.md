# WHU-sb Python SDK

Official Python SDK for the WHU-sb (武汉大学课程评价系统) API.

## Installation

```bash
pip install requests
```

## Usage

```python
from whu_sb import WHUSBClient

# Initialize the client
client = WHUSBClient(
    api_key="your_api_key",
    api_secret="your_api_secret",
    base_url="https://whu.sb/api/v1"
)

# Search for a course
results = client.search_courses(query="计算机")
for course in results['items']:
    print(f"{course['name']} (ID: {course['id']})")

# Get course detail
course = client.get_course(course_uid="CS101")
print(course['name'])
```

## Features

- **Course**: Search, Get by UID/ID, Get teachers, Get reviews
- **Teacher**: Search, Get by UID/ID, Get courses
- **Review**: Search, Get by UID/ID, Submit review
- **Search**: Simple and Advanced search
- **Suggest**: Search suggestions

## Contributing

Please report issues or submit PRs.
