# WHU-sb Ruby SDK

Official Ruby SDK for the WHU-sb (武汉大学课程评价系统) API.

## Installation

Add this to your `Gemfile`:

```ruby
gem 'whu_sb', '~> 1.0.0'
```

And then execute:

```bash
bundle install
```

## Usage

```ruby
require 'whu_sb'

client = WHUSBSDK::Client.new(
  api_key: 'your_api_key',
  api_secret: 'your_api_secret',
  base_url: 'https://api.whu.sb/api/v1'
)

# Search for a course
results = client.search_courses('计算机')
results['items'].each do |course|
  puts "#{course['name']} (ID: #{course['id']})"
end
```

## Features

- Simple and clean interface
- Full coverage of Search, Course, Teacher, Review, and User APIs
- Secure signature generation

## License

MIT
