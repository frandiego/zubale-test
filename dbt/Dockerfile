FROM python:3.11-slim

USER root
WORKDIR /app

RUN pip install --no-cache-dir \
    dbt-postgres \
    schedule \
    requests \
    psycopg2-binary \
    typer


COPY . /app
COPY dbt/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"] 
