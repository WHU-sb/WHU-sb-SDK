# WHU-sb PHP SDK

Official PHP SDK for the WHU-sb (武汉大学课程评价系统) API.

## Requirements

- PHP 7.4 or higher
- `curl` extension
- `json` extension

## Installation

```bash
composer require whu-sb/sdk
```

## Usage

```php
use WHUSBSDK\Client;

$client = new Client([
    'apiKey' => 'your_api_key',
    'apiSecret' => 'your_api_secret',
    'baseUrl' => 'https://api.whu.sb/api/v1'
]);

// Search for a course
$results = $client->searchCourses('计算机');
foreach ($results['items'] as $course) {
    echo $course['name'] . " (ID: " . $course['id'] . ")\n";
}
```

## Features

- Support for all public endpoint (Course, Teacher, Review, Search, User)
- PSR-compliant code
- Secure signature header generation

## License

MIT
