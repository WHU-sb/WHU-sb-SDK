export interface SDKConfig {
  apiKey?: string;
  apiSecret?: string;
  baseUrl?: string;
}

export interface PagedResult<T> {
  success: boolean;
  data: {
    items: T[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
  message: string;
}

export interface Course {
  id: number;
  course_uid: string;
  name: string;
  course_type: string;
  averageRating: number;
  reviewCount: number;
  averageDifficulty: number;
  averageWorkload: number;
  averageTeachingQuality: number;
  averageCourseInterest: number;
}

export interface Teacher {
  id: number;
  teacher_uid: string;
  name: string;
  reviewCount: number;
}

/**
 * WHU-sb API SDK for JavaScript/TypeScript
 */
export class WHUSBClient {
  private config: SDKConfig;

  constructor(config: SDKConfig = {}) {
    const defaultBaseUrl = (typeof process !== 'undefined' && process.env?.WHUSB_API_BASE_URL)
      || 'https://api.whu.sb/api/v1';

    this.config = {
      baseUrl: defaultBaseUrl,
      ...config,
    };
    this.config.baseUrl = this.config.baseUrl?.replace(/\/$/, '') || defaultBaseUrl;
  }

  private async generateSignature(timestamp: number): Promise<string> {
    if (!this.config.apiKey || !this.config.apiSecret) {
      return '';
    }
    const payload = `${this.config.apiKey}${timestamp}${this.config.apiSecret}`;
    const encoder = new TextEncoder();
    const data = encoder.encode(payload);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }

  private async request<T>(method: string, endpoint: string, options: any = {}): Promise<T> {
    const url = `${this.config.baseUrl}/${endpoint.replace(/^\//, '')}`;
    const timestamp = Math.floor(Date.now() / 1000);

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'X-API-Key': this.config.apiKey || '',
      'X-Timestamp': timestamp.toString(),
    };

    if (this.config.apiSecret) {
      headers['X-Signature'] = await this.generateSignature(timestamp);
    }

    const response = await fetch(url, {
      method,
      headers,
      body: options.body ? JSON.stringify(options.body) : undefined,
      ...options,
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(`API Request Failed (${response.status}): ${result.message || response.statusText}`);
    }

    return result.data as T;
  }

  // --- Course APIs ---

  async listCourses(page: number = 1, limit: number = 20): Promise<{ items: Course[], total: number }> {
    return this.request('GET', `courses?page=${page}&limit=${limit}`);
  }

  async getCourse(uid: string): Promise<Course> {
    return this.request('GET', `courses/${uid}`);
  }

  async searchCourses(query: string, page: number = 1, limit: number = 12): Promise<{ items: Course[], total: number }> {
    const encodedQuery = encodeURIComponent(query);
    return this.request('GET', `search/courses?query=${encodedQuery}&page=${page}&limit=${limit}`);
  }

  // --- Teacher APIs ---

  async listTeachers(page: number = 1, limit: number = 20): Promise<{ items: Teacher[], total: number }> {
    return this.request('GET', `teachers?page=${page}&limit=${limit}`);
  }

  async getTeacher(uid: string): Promise<Teacher> {
    return this.request('GET', `teachers/${uid}`);
  }

  // --- Search APIs ---

  async simpleSearch(query: string, scope: string = 'courses', page: number = 1, limit: number = 12): Promise<any> {
    const encodedQuery = encodeURIComponent(query);
    return this.request('GET', `search/simple?query=${encodedQuery}&scope=${scope}&page=${page}&limit=${limit}`);
  }

  async advancedSearch(query: string, filters: object = {}, page: number = 1, limit: number = 20): Promise<any> {
    return this.request('POST', 'search/advanced', {
      body: { query, filters, page, limit }
    });
  }

  async searchAll(query: string, page: number = 1, limit: number = 20): Promise<any> {
    const encodedQuery = encodeURIComponent(query);
    return this.request('GET', `search/all?query=${encodedQuery}&page=${page}&limit=${limit}`);
  }

  async getHotSearches(): Promise<string[]> {
    return this.request('GET', 'search/hot');
  }

  async queryBuilderSearch(query: string, scope: string = 'all', page: number = 1, limit: number = 20): Promise<any> {
    return this.request('POST', 'search/query-builder', {
      body: { query, scope, page, limit }
    });
  }

  // --- User APIs ---

  async getMe(): Promise<any> {
    return this.request('GET', 'users/me');
  }

  async getUserDashboard(): Promise<any> {
    return this.request('GET', 'users/dashboard');
  }

  async getUserProfile(): Promise<any> {
    return this.request('GET', 'users/profile');
  }

  async getUserNotifications(): Promise<any[]> {
    return this.request('GET', 'users/notifications');
  }

  // --- Translation APIs ---

  async translate(text: string, target: string): Promise<any> {
    return this.request('POST', 'translation/translate', {
      body: { text, target }
    });
  }

  async getTranslationStatus(): Promise<any> {
    return this.request('GET', 'translation/status');
  }
}
