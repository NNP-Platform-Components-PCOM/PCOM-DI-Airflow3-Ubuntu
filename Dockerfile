# syntax=docker/dockerfile:1.7
#
# PCOM - DI - Airflow3
# --------------------
# Apache Airflow 3.4.0 with Java 17, Spark 3.4.1, and MWAA-equivalent providers.
# DAGs and logs are stored in MinIO (S3-compatible).

FROM apache/airflow:3.4.0

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION="3.4.0"

LABEL org.opencontainers.image.title="pcom-di-airflow3-ubuntu" \
      org.opencontainers.image.description="Apache Airflow 3.4.0 with Spark 3.4.1, Python 3.11, and MWAA-equivalent providers for NNP Data Ingestion." \
      org.opencontainers.image.vendor="Nubo Native Platform" \
      org.opencontainers.image.source="https://github.com/NNP-Platform-Components-PCOM/PCOM-DI-Airflow3-Ubuntu" \
      org.opencontainers.image.url="https://github.com/NNP-Platform-Components-PCOM/PCOM-DI-Airflow3-Ubuntu" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

USER root

# Java 17, wget, and Python 3.11 (matches Spark 3.4.1 cluster Python version).
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget python3.11 python3.11-venv python3.11-dev python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Spark 3.4.1 to match the standalone cluster version.
# Use SPARK_HOME=/opt/spark-3.4.1 and PYSPARK_PYTHON=/opt/venv-py311/bin/python3.11 when submitting.
RUN wget -q https://archive.apache.org/dist/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz && \
    tar -xzf spark-3.4.1-bin-hadoop3.tgz -C /opt && \
    mv /opt/spark-3.4.1-bin-hadoop3 /opt/spark-3.4.1 && \
    rm spark-3.4.1-bin-hadoop3.tgz && \
    chown -R airflow:root /opt/spark-3.4.1

ENV SPARK_HOME=/opt/spark-3.4.1
ENV PATH=$SPARK_HOME/bin:$PATH

# Python 3.11 venv with pyspark for Spark client mode (driver must match executor Python version).
RUN python3.11 -m venv /opt/venv-py311 && \
    /opt/venv-py311/bin/pip install --no-cache-dir pyspark==3.4.1 && \
    chown -R airflow:root /opt/venv-py311

USER airflow

# MWAA-equivalent providers + project-specific packages.
RUN pip install --no-cache-dir \
    apache-airflow-providers-amazon \
    apache-airflow-providers-apache-spark \
    apache-airflow-providers-postgres \
    apache-airflow-providers-mysql \
    apache-airflow-providers-http \
    apache-airflow-providers-ssh \
    apache-airflow-providers-celery \
    apache-airflow-providers-cncf-kubernetes \
    apache-airflow-providers-slack \
    airflow-code-editor \
    black \
    isort \
    boto3 \
    PyMySQL==1.1.2 \
    minio==7.2.10 \
    fs-s3fs \
    langchain_text_splitters \
    langchain_huggingface \
    sentence-transformers
