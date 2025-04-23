from flask import Flask, render_template, request
import requests
import os
import re

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    weather = None
    error = None
    country = ""
    city = ""

    if request.method == "POST":
        country = request.form.get("country", "").strip().upper()
        city = request.form.get("city", "").strip()
        api_key = os.getenv("WEATHER_API_KEY", "9b2c4d0138b1218c91b49da94d63ac14")

        # 1. Walidacja ISO country code
        if not re.match(r"^[A-Z]{2}$", country):
            error = "Kod kraju musi być w formacie ISO (np. PL, DE, US)."
        elif not city:
            error = "Proszę podać miasto."
        else:
            # 2. Sprawdzamy czy miasto istnieje i czy pasuje do kraju
            geo_url = f"http://api.openweathermap.org/geo/1.0/direct?q={city}&limit=5&appid={api_key}"
            try:
                geo_resp = requests.get(geo_url, timeout=5)
                geo_data = geo_resp.json()

                # 3. Czy istnieje takie miasto w tym kraju
                location = next((loc for loc in geo_data if loc.get("country", "").upper() == country), None)

                if not geo_data:
                    error = "Podane miasto nie istnieje."
                elif not location:
                    error = "Podane miasto nie znajduje się w wybranym kraju."
                else:
                    # 4. Pobieramy pogodę z lat/lon
                    lat = location["lat"]
                    lon = location["lon"]
                    weather_url = (
                        f"https://api.openweathermap.org/data/2.5/weather"
                        f"?lat={lat}&lon={lon}&appid={api_key}&units=metric&lang=pl"
                    )
                    weather_resp = requests.get(weather_url, timeout=5)
                    data = weather_resp.json()

                    if weather_resp.status_code == 200 and "main" in data:
                        weather = {
                            "temperature": data["main"]["temp"],
                            "humidity":    data["main"]["humidity"],
                            "pressure":    data["main"]["pressure"],
                            "description": data["weather"][0]["description"]
                        }
                    elif weather_resp.status_code == 401:
                        error = "Nieprawidłowy klucz API. Sprawdź konfigurację."
                    else:
                        error = data.get("message", "Nie udało się pobrać pogody.")
            except requests.RequestException as e:
                error = f"Błąd sieci: {e}"

    return render_template(
        "index.html",
        weather=weather,
        error=error,
        country=country,
        city=city
    )

# Info o uruchomieniu
if __name__ == "__main__":
    import datetime
    print(f"Aplikacja uruchomiona: {datetime.datetime.now():%Y-%m-%d %H:%M:%S}")
    print("Autor: Kacper Zuk")
    print("Nasłuch na porcie: 5000")
    app.run(host="0.0.0.0", port=5000)
