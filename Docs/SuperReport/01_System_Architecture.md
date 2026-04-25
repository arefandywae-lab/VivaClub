# 01: System Architecture - Backend & Infrastructure

## 1. Architectural Pattern
The system follows a **Monolithic Core with Micro-services for Real-time Media**. This approach was chosen to ensure rapid development of complex business logic (Django) while delegating high-load media processing to specialized engines (LiveKit).

## 2. Backend Stack (The Engine)
- **Django Framework:** Used for its robust ORM, security features, and REST API capabilities.
- **Django Channels:** Extends Django to handle asynchronous protocols like WebSockets, essential for real-time chat and notification signaling.
- **PostgreSQL:** The primary relational database for user profiles, clinical records, and transaction logs.
- **Redis:** Acts as both a caching layer and the channel layer for WebSockets, enabling fast message passing between server instances.

## 3. Real-time Media Infrastructure
- **LiveKit Server:** A cutting-edge WebRTC SFU (Selective Forwarding Unit). It handles all audio/video streams, managing bandwidth and ensuring low-latency communication even on mobile networks.
- **Webhooks:** The backend listens to LiveKit events (e.g., room ended) to automatically update clinical records and billing statuses.

## 4. Infrastructure & Deployment (The Foundation)
- **Docker & Docker Compose:** Containerization ensures consistency between development and production environments.
- **Caddy Server:** A modern web server that provides automatic HTTPS (TLS) and acts as a reverse proxy for the Django application and LiveKit.
- **Firebase Cloud Messaging (FCM):** Used for push notifications to re-engage users and alert doctors of SOS calls.

## 5. Scalability Considerations
The architecture is designed to scale horizontally:
- **Stateless APIs:** API instances can be scaled behind a load balancer.
- **Media Scaling:** LiveKit can be deployed in a multi-node cluster for global availability.
