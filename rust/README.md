# WHU-sb Rust SDK

Official Rust SDK for the WHU-sb (武汉大学课程评价系统) API.

## Requirements

- Rust 1.56+
- `reqwest` for HTTP
- `serde` for serialization

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
whu-sb-sdk = "1.0.0"
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
```

## Usage

```rust
use whu_sb_sdk::WHUSBClient;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = WHUSBClient::new(
        Some("your_api_key".to_string()),
        Some("your_api_secret".to_string()),
        "https://api.whu.sb/api/v1".to_string(),
    );

    // Search for a course
    let results = client.search_courses("计算机", 1, 10).await?;
    for course in results.items {
        println!("{}: {}", course.id, course.name);
    }

    Ok(())
}
```

## Features

- Fully async (tokio/reqwest)
- Strongly typed Course, Teacher, Review models
- Full API coverage including search and user profile
- Secure signature generation

## License

MIT
