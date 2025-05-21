#!/bin/bash

API_KEY="039d4d269a7044e5b6b233507251605"
LOCATION="46268"

response=$(curl -s "http://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$LOCATION&aqi=no")

temp=$(echo "$response" | jq '.current.temp_f')
condition=$(echo "$response" | jq -r '.current.condition.text')

case "$condition" in
  *Sunny*|*Clear*) icon="" ;;   # nf-weather-day_sunny
  *Partly*)         icon="" ;;   # nf-weather-day_cloudy
  *Cloud*|*Overcast*) icon="" ;; # nf-weather-cloud
  *Rain*|*Drizzle*) icon="" ;;   # nf-weather-rain
  *Thunder*)        icon="" ;;   # nf-weather-storm_showers
  *Snow*)           icon="" ;;   # nf-weather-snow
  *Fog*|*Mist*)     icon="" ;;   # nf-weather-fog
  *)                icon="" ;;   # nf-weather-na
esac
echo "$icon ${temp}°F, $condition"
