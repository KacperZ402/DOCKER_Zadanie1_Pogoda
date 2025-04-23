# Projekt: Aplikacja pogodowa w kontenerze Docker

## Autor
**Kacper Żuk**

## Repozytoria
- GitHub: [https://github.com/KacperZ402/DOCKER_Zadanie1_Pogoda]
- DockerHub: [https://hub.docker.com/r/gwidon34/pogodynka]
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
