FROM python:3.11-slim
WORKDIR /app
# Run as non-root user
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
COPY . .
ENV PATH="/home/appuser/.local/bin:$PATH"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]