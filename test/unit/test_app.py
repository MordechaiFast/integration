from unittest.mock import patch

from redis import ConnectionError


@patch("page_tracker.app.redis")
def test_call_redis_incr(mock_redis, http_client):
    mock_redis.incr.return_value = 10
    response = http_client.get("/")
    assert response.status_code == 200
    assert response.text == "This page has been viewed 10 times."
    mock_redis.incr.assert_called_once_with("page_views")


@patch("page_tracker.app.redis")
def test_handle_redis_connection_error(mock_redis, http_client):
    mock_redis.incr.side_effect = ConnectionError
    response = http_client.get("/")
    assert response.status_code == 500
    assert response.text == "Internal error \N{PENSIVE FACE}"
