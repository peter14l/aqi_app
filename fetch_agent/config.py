from functools import lru_cache
import os

class Settings:
    #AQICN (WAQI) token (https://aqicn.org/data-platform/token/)
    AQICN_TOKEN = os.getenv('WAQI_API_TOKEN',"")
    REQUEST_TIMEOUT = float(os.env("REQUEST_TIMEOUT", "8.0"))

@lru_cache
def get_settings():
    return Settings()