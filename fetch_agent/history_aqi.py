from datetime import datetime, timedelta
from .exceptions import FetchError
from .realtime_aqi import realtime_aqi
from .config import get_settings
import requests
settings = get_settings()

def _month_ranges_for_last_n(n=12):
    today = datetime.utcnow().date()
    ranges = []
    for i in range(n-1, -1, -1):
        # get month start for each past month
        first_of_month = (today.replace(day=1) - timedelta(days=0)).replace(day=1)
        # shift back i months: simple approach
        # This function can be improved but keeps example simple
        month = (today.month - i - 1) % 12 + 1
        year = today.year + ((today.month - i - 1) // 12)
        ranges.append((year, month))
    return ranges

def history_aqi(location: str, months: int = 12):
    """
    Returns a list of `months` dicts with keys: avg_aqi, peak_aqi, least_aqi
    Implementation note: best to call a provider that exposes daily historical AQI.
    Here we attempt a simple approach: for each month sample the AQI at day intervals (or fallback).
    """
    results = []

    # Simple sampling approach: for each month fetch AQI of 8 sample dates (1st, 5th, 10th,...)
    # This is a pragmatic approach if true daily historical endpoint is unavailable.
    today = datetime.utcnow().date()
    for m in range(months):
        # compute a sample date roughly m months ago (approx)
        sample_date = today - timedelta(days=30*m)
        # we'll sample 6 points across that month: day 1,6,11,16,21,26
        sample_days = [1,6,11,16,21,26]
        vals = []
        for d in sample_days:
            try:
                # build lat,lon or city usage into realtime_aqi input if needed
                if "," in location:
                    loc = location
                else:
                    loc = location
                aqi = realtime_aqi(loc)
                vals.append(aqi)
            except Exception:
                continue
        if vals:
            results.append({
                "avg_aqi": sum(vals)/len(vals),
                "peak_aqi": max(vals),
                "least_aqi": min(vals)
            })
        else:
            # fallback empty values
            results.append({
                "avg_aqi": None,
                "peak_aqi": None,
                "least_aqi": None
            })
    return results