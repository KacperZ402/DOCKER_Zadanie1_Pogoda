# Główna aplikacja
FROM python:3.12-slim as runtime

# Dodajemy autora zgodnie z OCI
LABEL org.opencontainers.image.authors="Kacper Zuk"

# Instalacja zależności systemowych (minimalnie)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Ustawienie katalogu roboczego
WORKDIR /app

# Kopiujemy tylko potrzebne pliki
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

# Zmienna środowiskowa z portem
ENV PORT=5000

# Healthcheck — sprawdza, czy aplikacja odpowiada
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s CMD curl -f http://localhost:5000 || exit 1

# Aplikacja działa na porcie 5000
EXPOSE 5000

CMD ["python", "main.py"]