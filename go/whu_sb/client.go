package whusb

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// Client WHU-sb API Go SDK Client
type Client struct {
	APIKey    string
	APISecret string
	BaseURL   string
	HTTPClient *http.Client
}

// NewClient Create a new Go SDK Client
func NewClient(apiKey, apiSecret, baseURL string) *Client {
	return &Client{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   strings.TrimSuffix(baseURL, "/"),
		HTTPClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// Common response types
type APIResponse struct {
	Success bool            `json:"success"`
	Data    json.RawMessage `json:"data"`
	Message string          `json:"message"`
}

type PagedResult[T any] struct {
	Items      []T `json:"items"`
	Total      int `json:"total"`
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	TotalPages int `json:"totalPages"`
}

// Model types
type Course struct {
	ID                     uint64  `json:"id"`
	CourseUID              string  `json:"course_uid"`
	Name                   string  `json:"name"`
	CourseType             string  `json:"course_type"`
	AverageRating          float64 `json:"averageRating"`
	ReviewCount            int     `json:"reviewCount"`
	AverageDifficulty      float64 `json:"averageDifficulty"`
	AverageWorkload        float64 `json:"averageWorkload"`
	AverageTeachingQuality float64 `json:"averageTeachingQuality"`
	AverageCourseInterest  float64 `json:"averageCourseInterest"`
}

type Teacher struct {
	ID         uint64 `json:"id"`
	TeacherUID string `json:"teacher_uid"`
	Name       string `json:"name"`
	ReviewCount int    `json:"reviewCount"`
}

// Private helper for making requests
func (c *Client) request(method, endpoint string, body interface{}, result interface{}) error {
	url := fmt.Sprintf("%s/%s", c.BaseURL, strings.TrimPrefix(endpoint, "/"))

	var bodyReader io.Reader
	if body != nil {
		jsonData, err := json.Marshal(body)
		if err != nil {
			return err
		}
		bodyReader = bytes.NewBuffer(jsonData)
	}

	req, err := http.NewRequest(method, url, bodyReader)
	if err != nil {
		return err
	}

	timestamp := time.Now().Unix()
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-API-Key", c.APIKey)
	req.Header.Set("X-Timestamp", strconv.FormatInt(timestamp, 10))

	if c.APISecret != "" {
		payload := fmt.Sprintf("%s%d%s", c.APIKey, timestamp, c.APISecret)
		hash := sha256.Sum256([]byte(payload))
		req.Header.Set("X-Signature", hex.EncodeToString(hash[:]))
	}

	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= http.StatusBadRequest {
		var apiResp APIResponse
		if err := json.NewDecoder(resp.Body).Decode(&apiResp); err == nil {
			return fmt.Errorf("API Error (%d): %s", resp.StatusCode, apiResp.Message)
		}
		return fmt.Errorf("API request failed with status code %d", resp.StatusCode)
	}

	var apiResp APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return err
	}

	if result != nil {
		return json.Unmarshal(apiResp.Data, result)
	}

	return nil
}

// Course APIs

func (c *Client) SearchCourses(query string, page, limit int) (*PagedResult[Course], error) {
	var result PagedResult[Course]
	endpoint := fmt.Sprintf("search/courses?query=%s&page=%d&limit=%d", query, page, limit)
	err := c.request("GET", endpoint, nil, &result)
	return &result, err
}

func (c *Client) GetCourse(uid string) (*Course, error) {
	var result Course
	err := c.request("GET", "courses/"+uid, nil, &result)
	return &result, err
}

func (c *Client) ListCourses(page, limit int) (*PagedResult[Course], error) {
	var result PagedResult[Course]
	endpoint := fmt.Sprintf("courses?page=%d&limit=%d", page, limit)
	err := c.request("GET", endpoint, nil, &result)
	return &result, err
}

// Teacher APIs

func (c *Client) ListTeachers(page, limit int) (*PagedResult[Teacher], error) {
	var result PagedResult[Teacher]
	endpoint := fmt.Sprintf("teachers?page=%d&limit=%d", page, limit)
	err := c.request("GET", endpoint, nil, &result)
	return &result, err
}

func (c *Client) GetTeacher(uid string) (*Teacher, error) {
	var result Teacher
	err := c.request("GET", "teachers/"+uid, nil, &result)
	return &result, err
}

// Search APIs

func (c *Client) SimpleSearch(query, scope string, page, limit int) (*PagedResult[json.RawMessage], error) {
	var result PagedResult[json.RawMessage]
	endpoint := fmt.Sprintf("search/simple?query=%s&scope=%s&page=%d&limit=%d", query, scope, page, limit)
	err := c.request("GET", endpoint, nil, &result)
	return &result, err
}

func (c *Client) SearchAll(query string, page, limit int) (*PagedResult[json.RawMessage], error) {
	var result PagedResult[json.RawMessage]
	endpoint := fmt.Sprintf("search/all?query=%s&page=%d&limit=%d", query, page, limit)
	err := c.request("GET", endpoint, nil, &result)
	return &result, err
}

func (c *Client) GetHotSearches() ([]string, error) {
	var result []string
	err := c.request("GET", "search/hot", nil, &result)
	return result, err
}

func (c *Client) QueryBuilderSearch(query, scope string, page, limit int) (*PagedResult[json.RawMessage], error) {
	var result PagedResult[json.RawMessage]
	body := map[string]interface{}{
		"query": query,
		"scope": scope,
		"page":  page,
		"limit": limit,
	}
	err := c.request("POST", "search/query-builder", body, &result)
	return &result, err
}

// User APIs

func (c *Client) GetMe() (json.RawMessage, error) {
	var result json.RawMessage
	err := c.request("GET", "users/me", nil, &result)
	return result, err
}

func (c *Client) GetUserDashboard() (json.RawMessage, error) {
	var result json.RawMessage
	err := c.request("GET", "users/dashboard", nil, &result)
	return result, err
}

// Translation APIs

func (c *Client) Translate(text, target string) (json.RawMessage, error) {
	var result json.RawMessage
	body := map[string]string{
		"text":   text,
		"target": target,
	}
	err := c.request("POST", "translation/translate", body, &result)
	return result, err
}
