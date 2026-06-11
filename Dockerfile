FROM python:3.11-slim

# The stack uses PyMySQL (pure Python), so no MySQL C client or compiler is
# needed. All dependencies in requirements.txt ship manylinux wheels.

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
