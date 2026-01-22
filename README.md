# Homelab Configuration

This repository contains Docker Compose configurations for various self-hosted services. The project is structured to ensure portability, security, and ease of deployment.

## Repository Structure

Each service is organized into its own directory containing a `docker-compose.yml` file and its specific configuration requirements.

- `service-name/`
  - `docker-compose.yml` : The deployment manifest.
  - `.env` : Local environment variables (not tracked by Git).

## Security and Best Practices

To protect sensitive information and maintain a clean repository:

1. **Environment Variables**: Sensitive data such as IP addresses, passwords, and timezones are stored in `.env` files.
2. **Git Ignore**: A global `.gitignore` is used to prevent the leakage of secret keys and persistent application data.
3. **Template Files**: An `.env.example` file is provided at the root to outline required variables for new deployments.

## Deployment

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```