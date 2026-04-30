# sse-ballerina

A simple [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) endpoint built with [Ballerina](https://ballerina.io/).

## Prerequisites

Install Ballerina Swan Lake Update 12 (2201.12.0) from [ballerina.io/downloads](https://ballerina.io/downloads/).

## Run

```bash
bal run
```

The server starts at `http://localhost:8000`.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Health check |
| GET | `/events` | SSE stream — emits one event per second |

## Usage

**curl:**
```bash
curl -N http://localhost:8000/events
```

**JavaScript (browser):**
```js
const source = new EventSource('http://localhost:8000/events');
source.onmessage = (e) => console.log(e.data);
```

**Output:**
```
data: message 1 at 14:32:01

data: message 2 at 14:32:02

data: message 3 at 14:32:03
```

## SSE Format

Each event follows the [SSE spec](https://html.spec.whatwg.org/multipage/server-sent-events.html):

```
data: <payload>\n\n
```

A blank line (`\n\n`) terminates each event.

## Build

```bash
bal build
```

Produces `target/bin/sse-0.1.0.jar`.
