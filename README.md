# Zubale Data Project

This project contains the data transformation and analytics workflows for Zubale, 
managed with [dbt](https://www.getdbt.com/) and Docker.

## Project Structure

- `dbt/` - Main dbt project directory, including models, seeds, macros, and configuration files.
- `docker-compose.yml` - Docker Compose file to orchestrate services for local development and testing.

## Getting Started

### Prerequisites
- [Docker](https://www.docker.com/)
- [dbt](https://docs.getdbt.com/docs/installation)


To manage services with Docker Compose:

```sh
docker-compose up  --build -d     # Start services
/docker-compose down              # Stop services
```

## Directory Details

- `docker-compose.yml` - Docker Compose configuration file that defines and orchestrates three services:
  - `postgres`: PostgreSQL 15 database service exposed on port 5432
  - `dbt`: Custom dbt service built from Dockerfile with environment variables for database connection and currency API
  - `sqlpad`: SQL editor web interface running on port 3000 with preconfigured connection to Postgres
- `dbt/models/` - dbt models organized by domain (e.g., `silver/`, `analysis/`)
- `dbt/seeds/` - CSV files for seeding the database (*products.csv* and *orders.csv*)
- `dbt/hourly_currency_rate.py` - Python script that fetches hourly currency exchange rates from FreeCurrencyAPI and stores them in the database.
- `.env` - Environment variables configuration file containing

## Summary
When you run `make up`, the following happens:

1. Docker builds and starts all services defined in docker-compose.yml:

   - Postgres database:
     - Creates a new PostgreSQL 15 instance
     - Sets up database credentials from environment variables
     - Creates persistent volume for data storage
     - Exposes port 5432

   - dbt service:
     - Builds custom image from ./dbt/Dockerfile
     - Mounts ./dbt and ./shared directories
     - Configures connection to Postgres
     - Sets up environment variables for currency API

   - SQLPad:
     - Starts SQLPad web interface
     - Configures admin user and Postgres connection
     - Exposes web UI on port 3000

2. Services are started in the correct order based on dependencies:
   - Postgres starts first
   - dbt and SQLPad start after Postgres is ready

3. The -d flag runs everything in detached mode (background)

You can then:
- Access Postgres on localhost:5432
- Use SQLPad web interface on localhost:3000
- Run dbt commands through the dbt service

To stop all services, run `make stop` which will:
- Stop all running containers
- Remove containers and networks
- Preserve persistent volume data


## Solutions
As you can see I have complicated the project a bit to make it more challenging and to show my seniority. Let me explain my proposed solution.

I have created an application managed with docker-compose and as you can see it has three services `postgres` (the database), `dbt` the data management using python and [dbt](https://www.getdbt.com/) and `sqlpad` a client to do sql and visualizations over the database.

Once the `make up` service is up you can access this client at [localhost:3000][localhost:3000]

The **dbt** service will upload the `products.csv` and `orders.csv` csv in [dbt/seeds][./dbt/seeds]

* It will also create a service that generates the `currency_rates` table and updates it every hour, you can see the python code that generates it in `dbt/hourly_currency_rate.py`.

* The solution to the proposed sql queries as `dbt/models/silver/orders_full_information.sql` and as `dbt/models/silver/fixed_orders_full_information.sql`. As you can see the table that uses the ratios is a view, this means that it will give the price with the last rate obtained.

* We can also see the proposed sql's in the table analysis:     
    * [dbt/models/analysis/max_amount_orders_date.sql](./dbt/models/analysis/max_amount_orders_date.sql)
    * [dbt/models/analysis/most_demanded_product.sql](./dbt/models/analysis/most_demanded_product.sql)
    * [dbt/models/analysis/top_three_categories_by_demand.sql](./dbt/models/analysis/top_three_categories_by_demand.sql)

