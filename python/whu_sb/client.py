import os
import requests
import hashlib
import time
import json
from typing import Dict, List, Optional, Any

class WHUSBClient:
    """WHU-sb API Client SDK for Python 3.8+"""

    def __init__(self, api_key: Optional[str] = None, api_secret: Optional[str] = None, base_url: Optional[str] = None):
        self.api_key = api_key
        self.api_secret = api_secret
        if base_url is None:
            base_url = os.environ.get("WHUSB_API_BASE_URL", "https://api.whu.sb/api/v1")
        self.base_url = base_url.rstrip("/")

    def _generate_signature(self, timestamp: int) -> str:
        """Helper to generate an API signature if needed."""
        if not self.api_key or not self.api_secret:
            return ""
        # Example signature logic - depends on backend implementation
        payload = f"{self.api_key}{timestamp}{self.api_secret}"
        return hashlib.sha256(payload.encode()).hexdigest()

    def _request(self, method: str, endpoint: str, params: Optional[Dict] = None, data: Optional[Dict] = None) -> Any:
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        timestamp = int(time.time())
        
        headers = {
            "Content-Type": "application/json",
            "X-API-Key": self.api_key if self.api_key else "",
            "X-Timestamp": str(timestamp),
        }
        
        if self.api_secret:
            headers["X-Signature"] = self._generate_signature(timestamp)

        response = requests.request(method, url, params=params, json=data, headers=headers)
        
        if response.status_code >= 400:
            try:
                error_data = response.json()
                message = error_data.get("message", response.text)
            except:
                message = response.text
            raise Exception(f"API Request Failed ({response.status_code}): {message}")
        
        return response.json().get("data", response.json())

    # --- Course APIs ---

    def list_courses(self, page: int = 1, limit: int = 20) -> Dict:
        return self._request("GET", "courses", params={"page": page, "limit": limit})

    def get_course(self, course_uid: str) -> Dict:
        return self._request("GET", f"courses/{course_uid}")

    def get_course_by_id(self, course_id: int) -> Dict:
        return self._request("GET", f"courses/id/{course_id}")

    def get_course_teachers(self, course_uid: str) -> List:
        return self._request("GET", f"courses/{course_uid}/teachers")

    def get_course_reviews(self, course_uid: str) -> Dict:
        return self._request("GET", f"courses/{course_uid}/reviews")

    # --- Teacher APIs ---

    def list_teachers(self, page: int = 1, limit: int = 20) -> Dict:
        return self._request("GET", "teachers", params={"page": page, "limit": limit})

    def get_teacher(self, teacher_uid: str) -> Dict:
        return self._request("GET", f"teachers/{teacher_uid}")

    # --- Search & Suggest APIs ---

    def search_all(self, query: str, page: int = 1, limit: int = 20) -> Dict:
        return self._request("GET", "search/all", params={"query": query, "page": page, "limit": limit})

    def get_hot_searches(self) -> List:
        return self._request("GET", "search/hot")

    def query_builder_search(self, query: str, scope: str = "all", page: int = 1, limit: int = 20) -> Dict:
        return self._request("POST", "search/query-builder", data={"query": query, "scope": scope, "page": page, "limit": limit})

    # --- User APIs ---

    def get_me(self) -> Dict:
        return self._request("GET", "users/me")

    def get_user_activity(self) -> Dict:
        return self._request("GET", "users/activity")

    def get_user_dashboard(self) -> Dict:
        return self._request("GET", "users/dashboard")

    def get_user_notifications(self) -> List:
        return self._request("GET", "users/notifications")

    # --- External/HAM APIs ---

    def get_ham_course_stat(self, course_uid: str) -> Dict:
        return self._request("GET", "external/ham/score/stat/uid", params={"uid": course_uid})

    # --- Translation APIs ---

    def translate(self, text: str, target_lang: str) -> Dict:
        return self._request("POST", "translation/translate", data={"text": text, "target": target_lang})

    def get_translation_status(self) -> Dict:
        return self._request("GET", "translation/status")

    # --- Review APIs ---

    def submit_review(self, course_id: int, teacher_ids: List[int], content: str, 
                      difficulty: int, workload: int, quality: int, interest: int, 
                      semester: str, year: int, grade: str = "", anonymous: bool = False) -> Dict:
        data = {
            "course_id": course_id,
            "teacher_ids": teacher_ids,
            "content": content,
            "difficulty": difficulty,
            "workload": workload,
            "teaching_quality": quality,
            "course_interest": interest,
            "semester": semester,
            "year": year,
            "grade": grade,
            "reviewer_name": "匿名用户" if anonymous else "",
        }
        return self._request("POST", "reviews", data=data)
