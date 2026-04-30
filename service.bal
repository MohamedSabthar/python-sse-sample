import ballerina/http;
import ballerina/lang.runtime;
import ballerina/time;

class EventStream {
    private int count = 0;

    public isolated function next() returns record {|http:SseEvent value;|}|error? {
        self.count += 1;
        string timestamp = time:utcToString(time:utcNow()).substring(11, 19);
        json data = {value: string`message ${self.count} at ${timestamp}`};
        runtime:sleep(1);
        return {value: {data: data.toJsonString()}};
    }
}

service / on new http:Listener(8000) {
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
