# Application Deployment Setup

This folder contains the necessary configuration to build, orchestrate, and run the entire Document Management and RAG Q&A application stack using Docker Compose.

## Project Structure

This deployment setup assumes the following folder structure:

```
project_root/
├── deployment/
│   ├── docker-compose.yml
│   └── README.md
├── document-management-system/  (Backend Monorepo)
├── python-rag-service/          (Python Service)
└── document-management-frontend/  (Angular Frontend)
```

## Prerequisites

* [Docker](https://www.docker.com/products/docker-desktop/) and Docker Compose
* All project repositories (`document-management-system`, `python-rag-service`, `document-management-frontend`) cloned and placed in the structure shown above.

## Local Deployment Instructions

### 1. Configure Environment Variables
Create a `.env` file inside this `deployment` folder. This single file will provide the environment variables for all backend services.

**`deployment/.env` file:**
```env
# PostgreSQL connection URL
DATABASE_URL="postgresql://docker:docker@postgres:5432/auth_db?schema=public"

# Secret key for signing JWTs
JWT_SECRET="MySuperSecretKey123!@#"

# RabbitMQ connection URL
RABBITMQ_URI="amqp://guest:guest@rabbitmq:5672"
```
**Note:** The hostnames (`postgres`, `rabbitmq`) are used instead of `localhost` to allow containers to communicate with each other within the Docker network.

### 2. Build and Run the Application
Navigate to this `deployment` folder in your terminal and run the following command:

```bash
docker compose up --build
```
-   The `--build` flag tells Docker Compose to build the images for all services from their respective `Dockerfile`s. You only need to use this flag the first time or after making code changes.
-   To run the containers in the background (detached mode), use the `-d` flag: `docker compose up -d --build`.

### 3. Initialize the Database (First-Time Setup)
After the containers are running, you need to set up the database.

1.  **Apply Migrations:** From the `document-management-system` folder, run:
    ```bash
    npx prisma migrate dev
    ```
2.  **Enable `pgvector` and Create Tables:**
    -   Connect to the PostgreSQL container:
        ```bash
        docker exec -it postgres_db psql -U docker -d auth_db
        ```
    -   Inside the `psql` shell, run:
        ```sql
        CREATE EXTENSION IF NOT EXISTS vector;
        \q
        ```
    -   From the `python-rag-service` folder, run the setup script:
        ```powershell
        # For PowerShell
        Get-Content setup.sql | docker exec -i postgres_db psql -U docker -d auth_db
        ```

## Accessing the Application

Once everything is running, you can access the different parts of the application:

-   **Angular Frontend:** `http://localhost:4200`
-   **Backend Service APIs:** Ports `3001` through `3004` and `8000`.
-   **RabbitMQ Management UI:** `http://localhost:15672`
