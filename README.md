# Simple Inventory Management System

## First setup

Build the Docker image and start the application and PostgreSQL:

```bash
docker compose up --build
```

Run the database migrations and seed the database:

```bash
docker compose run --rm app rake db:migrate && docker compose run --rm app rake db:seed
```

The application will be available at:

```text
http://localhost:3050
```
