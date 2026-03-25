use reqwest::{Client, Method, RequestBuilder};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Clone)]
pub struct WHUSBClient {
    api_key: Option<String>,
    api_secret: Option<String>,
    base_url: String,
    http_client: Client,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Course {
    pub id: u64,
    pub course_uid: String,
    pub name: String,
    pub course_type: Option<String>,
    pub average_rating: Option<f64>,
    pub review_count: Option<u32>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct PagedResult<T> {
    pub items: Vec<T>,
    pub total: u32,
    pub page: u32,
    pub limit: u32,
    pub total_pages: u32,
}

#[derive(Deserialize)]
pub struct APIResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub message: String,
}

impl WHUSBClient {
    pub fn new(api_key: Option<String>, api_secret: Option<String>, base_url: Option<String>) -> Self {
        let final_url = base_url.unwrap_or_else(|| {
            std::env::var("WHUSB_API_BASE_URL").unwrap_or_else(|_| "https://api.whu.sb/api/v1".to_string())
        });
        Self {
            api_key,
            api_secret,
            base_url: final_url.trim_end_matches('/').to_string(),
            http_client: Client::new(),
        }
    }

    fn generate_signature(&self, timestamp: u64) -> String {
        if let (Some(key), Some(secret)) = (&self.api_key, &self.api_secret) {
            let payload = format!("{}{}{}", key, timestamp, secret);
            let mut hasher = Sha256::new();
            hasher.update(payload.as_bytes());
            let result = hasher.finalize();
            format!("{:x}", result)
        } else {
            String::new()
        }
    }

    async fn request<T, R>(&self, method: Method, endpoint: &str, query: Option<&[(String, String)]>, body: Option<&T>) -> Result<R, Box<dyn std::error::Error>>
    where
        T: Serialize + ?Sized,
        R: for<'de> Deserialize<'de>,
    {
        let url = format!("{}/{}", self.base_url, endpoint.trim_start_matches('/'));
        let now = SystemTime::now().duration_since(UNIX_EPOCH)?;
        let timestamp = now.as_secs();

        let mut builder = self.http_client.request(method, &url)
            .header("Content-Type", "application/json")
            .header("X-API-Key", self.api_key.as_deref().unwrap_or(""))
            .header("X-Timestamp", timestamp.to_string());

        if let Some(_) = &self.api_secret {
            builder = builder.header("X-Signature", self.generate_signature(timestamp));
        }

        if let Some(q) = query {
            builder = builder.query(q);
        }

        if let Some(b) = body {
            builder = builder.json(b);
        }

        let response = builder.send().await?;
        let api_resp: APIResponse<R> = response.json().await?;

        if !api_resp.success {
            return Err(api_resp.message.into());
        }

        api_resp.data.ok_or_else(|| "Empty data".into())
    }

    pub async fn list_courses(&self, page: u32, limit: u32) -> Result<PagedResult<Course>, Box<dyn std::error::Error>> {
        self.request::<(), PagedResult<Course>>(Method::GET, "/courses", Some(&[
            ("page".to_string(), page.to_string()),
            ("limit".to_string(), limit.to_string()),
        ]), None).await
    }

    pub async fn get_course(&self, uid: &str) -> Result<Course, Box<dyn std::error::Error>> {
        self.request::<(), Course>(Method::GET, &format!("/courses/{}", uid), None, None).await
    }

    pub async fn search_courses(&self, query: &str, page: u32, limit: u32) -> Result<PagedResult<Course>, Box<dyn std::error::Error>> {
        self.request::<(), PagedResult<Course>>(Method::GET, "/search/courses", Some(&[
            ("query".to_string(), query.to_string()),
            ("page".to_string(), page.to_string()),
            ("limit".to_string(), limit.to_string()),
        ]), None).await
    }
}
