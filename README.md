# PCOM-DI-Airflow3-Ubuntu

Apache Airflow 3.4.0 Docker image with Spark 3.4.1, MWAA-equivalent providers, and MinIO-backed DAG/log storage, built for the Nubo Native Platform.

## Image

```
docker.io/nubonativesolution/pcom-di-airflow3-ubuntu:3.4.0-v1
```

## Features

- **Airflow 3.4.0** on Debian Trixie (Python 3.13)
- **Spark 3.4.1** installed at `/opt/spark-3.4.1` for client-mode job submission
- **MinIO client (`mc`)** baked in for DAG sync sidecar
- **MWAA-equivalent providers** — same provider set as AWS Managed Airflow
- **CeleryExecutor** with direct Celery invocation (bypasses CLI wrapper bug)

## MWAA-Style Architecture

| Component | Backend |
|---|---|
| DAG storage | MinIO bucket `airflow3-dags` |
| Log storage | MinIO bucket `airflow3-logs` |
| Metadata DB | PostgreSQL (Patroni) |
| Task broker | Redis |
| Executor | CeleryExecutor |

## Included Providers

| Provider | Purpose |
|---|---|
| `apache-airflow-providers-amazon` | S3 / MinIO (remote logging + DAG sync) |
| `apache-airflow-providers-apache-spark` | SparkSubmitOperator |
| `apache-airflow-providers-postgres` | PostgreSQL connections |
| `apache-airflow-providers-mysql` | MySQL connections |
| `apache-airflow-providers-http` | HTTP hooks |
| `apache-airflow-providers-ssh` | SSH operator |
| `apache-airflow-providers-celery` | CeleryExecutor |
| `apache-airflow-providers-cncf-kubernetes` | KubernetesPodOperator |
| `apache-airflow-providers-slack` | Slack alerts |

## Additional Packages

| Package | Purpose |
|---|---|
| `airflow-code-editor` | In-browser DAG editor |
| `boto3` | AWS / MinIO SDK |
| `PyMySQL` | MySQL driver |
| `minio` | MinIO Python SDK |
| `fs-s3fs` | S3 filesystem abstraction |
| `pyspark==3.4.1` | PySpark matching cluster version |
| `langchain_text_splitters` | LLM text processing |
| `langchain_huggingface` | HuggingFace LLM integration |
| `sentence-transformers` | Embedding models |

## Deployment

Deploy using the [DMS deploy script](http://192.168.18.70/bigdata-management/deployment/dms-deploy-script):

```bash
ADMIN_PASS=xxx \
PATRONI_HOST=<patroni-ip> \
MINIO_HOST=<minio-ip> \
MINIO_ACCESS_KEY=xxx \
MINIO_SECRET_KEY=xxx \
APPS=airflow3 \
bash deploy-dms.sh
```

The script automatically creates the `airflow3` PostgreSQL database, generates the Fernet key, and starts the full stack.

## Ports

| Service | Port |
|---|---|
| Airflow UI | `8090` |
| Flower (worker monitor) | `5556` |

## CI/CD

Images are built and published to Docker Hub automatically on every push to `main` via the shared [PCOM-CICD](https://github.com/NNP-Platform-Components-PCOM/PCOM-CICD) pipeline.

| Tag | Description |
|---|---|
| `3.4.0-v1` | Airflow 3.4.0, patch version 1 |
| `latest` | Most recent build |
