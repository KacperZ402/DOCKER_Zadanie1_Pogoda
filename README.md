# Projekt: Aplikacja pogodowa w kontenerze Docker

## Autor
**Kacper Żuk**

## Repozytoria
- GitHub: [https://github.com/KacperZ402/DOCKER_Zadanie1_Pogoda]
- DockerHub: [https://hub.docker.com/r/gwidon34/zadanie1]
---

## 1. Opis aplikacji (część obowiązkowa)

### Funkcjonalność
Aplikacja webowa zbudowana we Flasku, uruchamiana jako kontener Dockera. Pozwala użytkownikowi wybrać kraj (kod ISO) i miasto, a następnie pobiera aktualną pogodę z API OpenWeather. Wyniki prezentowane są w interfejsie HTML.

### Informacje logowane przy starcie kontenera
Po uruchomieniu aplikacji w logach widoczne są:
- data uruchomienia,
- imię i nazwisko autora (Kacper Żuk),
- numer portu TCP (`5000`), na którym działa aplikacja.

Przykład logu:

Aplikacja uruchomiona: 2025-04-23 21:16:29
Autor: Kacper Zuk
Nasłuch na porcie: 5000
 * Serving Flask app 'main'
 * Debug mode: off

## 2. Dockerfile (część obowiązkowa)

### Opis
Plik Dockerfile buduje minimalistyczny obraz aplikacji z wykorzystaniem `python:3.9-slim`, z uwzględnieniem optymalizacji warstw i zależności.

-Wieloetapowe budowanie dla przejrzystości i ewentualnych rozszerzeń

-Minimalna baza slim dla mniejszego rozmiaru

-HEALTHCHECK zapewniający monitoring kontenera

3. Polecenia (część obowiązkowa)
a) Budowanie obrazu

    docker build -t pogodynka:latest .

b) Uruchomienie kontenera

    docker run -d -p 5000:5000 -e WEATHER_API_KEY=9b2c4d0138b1218c91b49da94d63ac14 --name pogodynka pogodynka:latest

c) Uzyskanie logów startowych

    docker logs pogodynka

d) Sprawdzenie warstw i rozmiaru obrazu

    docker image inspect pogodynka --format='{{.RootFS.Layers}}'
    docker image inspect pogodynka --format='{{.Size}}'

# Część zaawansowana – Budowanie wieloplatformowego obrazu z cache (max. +50%)
## Cel
### Zbudowanie zoptymalizowanego obrazu kontenera zgodnego z OCI, wspierającego platformy linux/amd64 oraz linux/arm64. Wykorzystano mechanizm cache (inline + registry) oraz builder oparty na docker-container.

Użyte narzędzia i konfiguracja
🛠 Builder typu docker-container
Builder został utworzony i aktywowany:
    docker buildx create --name multi-builder --driver docker-container --use
    docker buildx inspect --bootstrap
Dzięki temu możliwe było użycie wieloarchitektonicznego builda i efektywnego cache’owania.

### Budowa i publikacja obrazu z cache
Obraz został zbudowany i wypchnięty do Docker Hub w wersji wspierającej dwie architektury:


    docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag gwidon34/zadanie1:latest \
    --push \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from=type=registry,ref=gwidon34/zadanie1:buildcache \
    --cache-to=type=registry,ref=gwidon34/zadanie1:buildcache,mode=max \
    .

    docker buildx build --platform linux/amd64,linux/arm64 --tag gwidon34/zadanie1:latest --push --build-arg BUILDKIT_INLINE_CACHE=1 --cache-from=type=registry,ref=gwidon34/zadanie1:buildcache --cache-to=type=registry,ref=gwidon34/zadanie1:buildcache,mode=max .

✅ Obraz został wypchnięty do:
🔗 Docker Hub: https://hub.docker.com/r/gwidon34/zadanie1

📦 Sprawdzenie platform i manifestu
### Weryfikacja, że obraz wspiera amd64 i arm64:


    docker buildx imagetools inspect gwidon34/zadanie1:latest
✅ Manifest zawiera:

linux/amd64

linux/arm64

### Weryfikacja działania cache
Użyto BUILDKIT_INLINE_CACHE=1

Zastosowano cache push/pull do rejestru (--cache-to, --cache-from)

Kolejna budowa była znacząco szybsza, co potwierdza efektywne wykorzystanie cache'a

### Uruchomienie kontenera
    docker run -p 5000:5000 gwidon34/zadanie1:latest
### Sprawdzenie logów uruchomieniowych
    docker logs <container_id>
Przykładowy log:
    Aplikacja uruchomiona: 2025-04-23 21:16:29
    Autor: Kacper Zuk
    Nasłuch na porcie: 5000
### Sprawdzenie warstw i rozmiaru obrazu
    docker image inspect gwidon34/zadanie1:latest --format='{{.RootFS.Layers}}'
    docker image inspect gwidon34/zadanie1:latest --format='{{.Size}}'


   
