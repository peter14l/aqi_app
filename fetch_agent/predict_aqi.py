from datetime import datetime
from .realtime_aqi import realtime_aqi

def predict_aqi(lat_or_loc, lon=None, hour_of_day: int = None) -> int:
    """
    Simple rule-based predictor:
      - base = current aqi
      - morning/evening traffic bump
      - apply weather-based multiplier optionally (not included here)
    lat_or_loc: either a "lat,lon" string or a city name. If lon provided then lat_or_loc is lat.
    """
    # determine location input for realtime_aqi
    if lon is not None:
        location = f"{lat_or_loc},{lon}"
    else:
        location = lat_or_loc

    base = realtime_aqi(location)
    if hour_of_day is None:
        hour_of_day = datetime.utcnow().hour  # naive UTC hour; adjust for timezone if needed

    # rules (tweak to taste)
    if 5 <= hour_of_day < 9:
        # morning rush: +15%
        pred = int(base * 1.15)
    elif 17 <= hour_of_day < 21:
        # evening rush: +25%
        pred = int(base * 1.25)
    elif 0 <= hour_of_day < 5:
        pred = int(base * 0.8)  # lower at night
    else:
        pred = base

    # clamp
    if pred < 0:
        pred = 0
    return pred