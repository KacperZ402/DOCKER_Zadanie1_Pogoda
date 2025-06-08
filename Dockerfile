# Faza budowania (Build Stage)
FROM python:3.12-slim as builder

ARG BUILDKIT_INLINE_CACHE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# Faza uruchomieniowa (Runtime Stage)
FROM python:3.12-slim as runtime

LABEL org.opencontainers.image.authors="Kacper Zuk"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY app/ .

ENV PORT=5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s CMD curl -f http://localhost:5000 || exit 1

EXPOSE 5000

CMD ["python", "main.py"]
