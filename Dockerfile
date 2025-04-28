# Faza budowania (Build Stage)
FROM python:3.12-slim as builder

# Instalacja zależności systemowych (minimalnie)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Ustawienie katalogu roboczego dla fazy budowania
WORKDIR /app

# Kopiujemy tylko plik requirements.txt, aby instalować zależności
COPY requirements.txt .

# Instalacja zależności (tylko w fazie budowania)
RUN pip install --no-cache-dir --user -r requirements.txt

# Faza uruchomieniowa (Runtime Stage)
FROM python:3.12-slim as runtime

# Dodajemy autora zgodnie z OCI
LABEL org.opencontainers.image.authors="Kacper Zuk"

# Instalacja zależności systemowych (minimalnie)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Ustawienie katalogu roboczego
WORKDIR /app

# Kopiujemy zależności z fazy budowania (zainstalowane biblioteki)
COPY --from=builder /root/.local /root/.local

# Ustawienie zmiennej środowiskowej dla lokalizacji pakietów
ENV PATH=/root/.local/bin:$PATH

# Kopiujemy aplikację do obrazu
COPY app/ .

# Zmienna środowiskowa z portem
ENV PORT=5000

# Healthcheck — sprawdza, czy aplikacja odpowiada
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s CMD curl -f http://localhost:5000 || exit 1

# Aplikacja działa na porcie 5000
EXPOSE 5000

# Uruchomienie aplikacji
CMD ["python", "main.py"]