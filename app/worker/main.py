import os
import time
import signal
import sys
import redis

running = True

# Graceful shutdown handling (catches SIGTERM from Kubernetes)
def handle_sigterm(*args):
    global running
    print("SIGTERM received. Finishing current task and shutting down...")
    running = False

signal.signal(signal.SIGTERM, handle_sigterm)

def get_redis():
    return redis.Redis(host=os.getenv("REDIS_HOST"), port=6379, db=0, decode_responses=True)

def main():
    r = get_redis()
    print("Worker started. Waiting for tasks...")
    
    while running:
        # brpop blocks for 2 seconds waiting for a task, then loops to check 'running' flag
        task = r.brpop("task_queue", timeout=2)
        if task:
            task_name = task[1]
            print(f"Processing task: {task_name}")
            time.sleep(3)  # Simulate heavy processing
            print(f"Finished task: {task_name}")
            
    print("Worker shut down cleanly.")

if __name__ == "__main__":
    main()