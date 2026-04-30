import ballerina/http;
import ballerina/log;

import xlibb/pipe;

isolated class EventEmitter {
    private final pipe:Pipe pipe = new (10);
    private final string serviceOrderId;
    private final boolean isMemberEmitter;
    private final string uniqueId;
    private boolean closed = false;
    private boolean isNew = true;

    isolated function init(string serviceOrderId, string uniqueId, boolean isMemberEmitter = false) {
        self.serviceOrderId = serviceOrderId;
        self.isMemberEmitter = isMemberEmitter;
        self.uniqueId = uniqueId;
    }

    isolated function addEvent(anydata event) returns error? {
        lock {
            if self.closed {
                return;
            }
        }
        check self.pipe.produce(event.cloneReadOnly(), timeout = 60);
    }

    public isolated function next() returns record {|http:SseEvent value;|}|error? {
        lock {
            if self.closed {
                return;
            }
        }
        lock {
            if self.isNew {
                self.isNew = false;
                return {value: {comment: "ping"}};
            }
        }

        anydata|pipe:Error interactionEvent = self.pipe.consume(timeout = 15);
        if interactionEvent is pipe:Error {
            log:printInfo("Event consumed: ", event = "ping");
            return {value: {comment: "ping"}};
        }
        log:printInfo("Event consumed: ", event = interactionEvent);
        return {value: {data: interactionEvent.toJsonString()}};
    }

    public isolated function close() returns error? {
        log:printInfo("Close triggered");
        lock {
            if self.closed {
                return;
            }
        }
        lock {
            self.closed = true;
        }
        error? err = self.pipe.immediateClose();
        if err is error {
            log:printError("Failed to close pipe: ", err);
        }
    }
}

type EventStream stream<http:SseEvent, error?>;

service / on new http:Listener(8000) {
    private final EventEmitter emitter = new ("test", "test");

    resource function post data(@http:Payload json data) returns json|error {
        check self.emitter.addEvent(data);
        return data;
    }

    resource function get events() returns http:Response|error {
        http:Response response = new;
        response.removeAllHeaders();
        EventStream myStream = new (self.emitter);
        response.setSseEventStream(myStream);
        response.addHeader("X-Accel-Buffering", "no");
        response.setHeader("Cache-Control", "no-cache, no-transform");
        response.setHeader("Content-Encoding", "identity");
        return response;
    }

    resource function get .() returns json {
        return {"message": "SSE server running. Connect to /events"};
    }
}
