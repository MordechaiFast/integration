FROM python:3.12.2-slim AS builder

RUN apt-get update && apt-get upgrade --yes

RUN useradd --create-home nonroot
USER nonroot
WORKDIR /home/nonroot

ENV VENV=/home/nonroot/venv
RUN python3 -m venv ${VENV}
ENV PATH="${VENV}/bin:${PATH}"

COPY --chown=nonroot pyproject.toml constraints.txt ./
RUN python -m pip install --upgrade pip setuptools &&\
    python -m pip install --no-cache-dir -c constraints.txt ".[dev]"

COPY --chown=nonroot src/ src/
COPY --chown=nonroot test/ test/

RUN python -m pip install . -c constraints.txt &&\
    pytest test/unit/ &&\
    ruff check src/ && ruff format src/ &&\
    python -m pip wheel --wheel-dir dist/ . -c constraints.txt

FROM python:3.12.2-slim

RUN apt-get update && apt-get upgrade --yes

RUN useradd --create-home nonroot
USER nonroot
WORKDIR /home/nonroot

ENV VENV=/home/nonroot/venv
RUN python3 -m venv ${VENV}
ENV PATH="${VENV}/bin:${PATH}"

COPY --from=builder /home/nonroot/dist/page_tracker*whl /home/nonroot

RUN python -m pip install --upgrade pip setuptools &&\
    python -m pip install --no-cache-dir page_tracker*.whl

ENV REDIS_URL=redis://172.17.0.1:6379

CMD ["flask", "--app", "page_tracker.app", "run", \
     "--host", "0.0.0.0", "--port", "5000"]
