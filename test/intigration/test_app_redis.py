import pytest


@pytest.mark.timeout(2)
def test_update_redis(redis_client, http_client):
    redis_client.set("page_views", 8)
    response = http_client.get("/")
    assert response.status_code == 200
    assert response.text == "This page has been viewed 9 times."
    assert redis_client.get("page_views") == b"9"
