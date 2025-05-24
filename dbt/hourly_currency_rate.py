"""
This script fetches the BRL to USD exchange rate from the FreeCurrencyAPI every hour
and stores it in a PostgreSQL database. It uses the 'schedule' library to run the task
periodically. The script creates the table 'brl_usd_rates' if it does not exist and
inserts the latest exchange rate along with a timestamp each time it runs.

Environment variables required:
- FREECURRENCYAPI_KEY: API key for FreeCurrencyAPI
- DBT_HOST: Hostname for PostgreSQL (default: localhost)
- DBT_PORT: Port for PostgreSQL (default: 5432)
- DBT_DB: Database name (default: mydatabase)
- DBT_USER: Username for PostgreSQL (default: postgres)
- DBT_PASSWORD: Password for PostgreSQL (default: postgres)
- CURRENCY_TABLE: Name of output table (default: brl_usd_rates)
"""
from datetime import datetime

import requests
import psycopg2
import schedule
import typer
import time
import os

app = typer.Typer()

def fetch_and_store_rate(
    currency: str,
    base_currency: str,
    output_schema: str,
    output_table: str
):
    """
    Fetches the exchange rate for the given currency and base_currency from FreeCurrencyAPI
    and stores it in the specified schema and table in PostgreSQL.
    """
    API_KEY = os.environ["API_KEY"]
    POSTGRES_HOST = os.environ["POSTGRES_HOST"]
    POSTGRES_PORT = int(os.environ.get("POSTGRES_PORT", 5432))
    POSTGRES_DB = os.environ["POSTGRES_DB"]
    POSTGRES_USER = os.environ["POSTGRES_USER"]
    POSTGRES_PASSWORD = os.environ["POSTGRES_PASSWORD"]


    url = f"https://api.freecurrencyapi.com/v1/latest?apikey={API_KEY}&currencies={currency}&base_currency={base_currency}"
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()
    rate = data["data"][currency]
    timestamp = datetime.utcnow()

    conn = psycopg2.connect(
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD
    )
    cur = conn.cursor()
    cur.execute(f"""
        CREATE SCHEMA IF NOT EXISTS {output_schema};
        CREATE TABLE IF NOT EXISTS {output_schema}.{output_table} (
            id SERIAL PRIMARY KEY,
            base_currency TEXT NOT NULL,
            currency TEXT NOT NULL,
            rate FLOAT NOT NULL,
            fetched_at TIMESTAMP NOT NULL
        );
    """)
    cur.execute(
        f"INSERT INTO {output_schema}.{output_table} (base_currency, currency, rate, fetched_at) VALUES (%s, %s, %s, %s);",
        (base_currency, currency, rate, timestamp)
    )
    conn.commit()
    print(f"Stored {base_currency} to {currency} rate: {rate} at {timestamp} in {output_schema}.{output_table}")
    cur.close()
    conn.close()


@app.command()
def main(
    currency: str = typer.Option(..., help="The target currency (e.g., USD)"),
    base_currency: str = typer.Option(..., help="The base currency (e.g., BRL)"),
    interval: int = typer.Option(1, help="Interval in hours to fetch the rate"),
    output_schema: str = typer.Option("dbt", help="Output schema in PostgreSQL"),
    output_table: str = typer.Option("currency_rates", help="Output table in PostgreSQL"),
    run_once: bool = typer.Option(False, help="If set, run once and exit (no scheduler)")
):
    """
    Fetches the exchange rate and stores it in PostgreSQL. Can run once or on a schedule.
    """
    if run_once:
        fetch_and_store_rate(currency, base_currency, output_schema, output_table)
    else:
        schedule.every(int(interval)).hours.at(":00").do(
            fetch_and_store_rate,
            currency=currency,
            base_currency=base_currency,
            output_schema=output_schema,
            output_table=output_table
        )
        # fetch_and_store_rate(currency, base_currency, output_schema, output_table) # run once 
        print(f"Scheduler started. Fetching {base_currency} to {currency} rate every {interval} hour(s). Output: {output_schema}.{output_table}")
        while True:
            schedule.run_pending()
            time.sleep(60)


if __name__ == "__main__":
    app() 