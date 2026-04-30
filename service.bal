import ballerina/http;

import xlibb/pipe;

isolated pipe:Pipe pipe = new (10);

class EventStream {
    private int count = 0;

    public isolated function next() returns record {|http:SseEvent value;|}|error? {
        self.count += 1;
        lock {
            json|error data = pipe.consume(timeout = 15);
            if data is json {
                return {value: {data: data.toJsonString()}};
            }
        }
        return {value: {comment: "ping"}};
    }
}

service / on new http:Listener(8000) {

    resource function post data(@http:Payload json data) returns json|error {
        lock {
            check pipe.produce(data.cloneReadOnly(), timeout = 10);
        }
        return data;
    }

    resource function get events() returns http:Response|error {
        http:Response response = new;
        stream<http:SseEvent, error?> mystream = new (new EventStream());
        response.setSseEventStream(mystream);
        response.addHeader("X-Accel-Buffering", "no");
        response.setHeader("Cache-Control", "no-cache, no-transform");
        return response;
    }

    resource function get .() returns json {
        return {"message": "SSE server running. Connect to /events"};
    }
}
