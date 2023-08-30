# Base Stage
FROM python:3.11-slim AS base

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1


# Python Dependencies Stage
FROM base AS python-deps

# Install poetry and compilation dependencies
RUN pip install poetry
RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Copy project files
WORKDIR /app
COPY pyproject.toml poetry.lock /app/

# Install python dependencies in virtual environment
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi


# Runtime Stage
FROM base AS runtime

# Copy virtual env from python-deps stage
COPY --from=python-deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=python-deps /usr/local/bin /usr/local/bin

# Create and switch to a new user
RUN useradd --create-home appuser
WORKDIR /home/appuser
USER appuser

# Copy application into container
COPY . .

# Run the executable
ENTRYPOINT ["python", "-m", "best_practices"]
CMD ["10"]
