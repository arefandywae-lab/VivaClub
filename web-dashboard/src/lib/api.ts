const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// Simple wrapper around fetch to include tokens and handle base URL
export async function apiFetch(endpoint: string, options: RequestInit = {}) {
    // In a real app, you'd get this from a cookie or localStorage
    const token = typeof window !== 'undefined' ? localStorage.getItem('adminToken') : null;

    const headers = new Headers(options.headers || {});
    headers.set('Content-Type', 'application/json');

    if (token) {
        headers.set('Authorization', `Bearer ${token}`);
    }

    const response = await fetch(`${API_URL}/api${endpoint}`, {
        ...options,
        headers,
    });

    if (!response.ok) {
        const errorBody = await response.json().catch(() => ({}));
        throw new Error(errorBody.error || `Request failed with status ${response.status}`);
    }

    if (response.status === 204) {
        return null;
    }

    return response.json();
}
