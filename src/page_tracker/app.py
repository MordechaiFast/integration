import os

from flask import Flask
from redis import Redis, RedisError

app = Flask(__name__)
redis = Redis.from_url(os.getenv("REDIS_URL", "redis://localhost:6379"))


@app.get("/")
def index():
    try:
        page_views = redis.incr("page_views")
    except RedisError:
        app.logger.exception("Redis eror")
        return "Internal error \N{PENSIVE FACE}", 500
    else:
        return f"This page has been viewed {page_views} times."
