import asyncio
import time
from fastapi import FastAPI
from fastapi.responses import StreamingResponse

app = FastAPI()


async def event_stream():
    count = 0
    while True:
        count += 1
        yield f"data: message {count} at {time.strftime('%H:%M:%S')}\n\n"
        await asyncio.sleep(1)


@app.get("/events")
async def sse():
    return StreamingResponse(event_stream(), media_type="text/event-stream")


@app.get("/")
async def root():
    return {"message": "SSE server running. Connect to /events"}
