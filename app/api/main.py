import os
import psycopg2
import redis
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(title="TaskFlow API")
# Expose Prometheus metrics at /metrics
Instrumentator().instrument(app).expose(app, endpoint="/metrics")

class Task(BaseModel):
    name: str

def get_db():
    return psycopg2.connect(os.getenv("DATABASE_URL"))

def get_redis():
    return redis.Redis(host=os.getenv("REDIS_HOST"), port=6379, db=0, decode_responses=True)

@app.get("/healthz")
def healthz():
    """Liveness probe: Is the app running?"""
    return {"status": "alive"}

@app.get("/readyz")
def readyz():
    """Readiness probe: Can we connect to dependencies?"""
    try:
        db = get_db(); db.close()
        r = get_redis(); r.ping()
        return {"status": "ready"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Dependency check failed: {str(e)}")

@app.post("/tasks")
def create_task(task: Task):
    """Accept a task and push it to the Redis queue"""
    r = get_redis()
    r.lpush("task_queue", task.name)
    return {"message": "Task queued successfully", "task": task.name}