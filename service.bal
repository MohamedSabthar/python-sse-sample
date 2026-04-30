import ballerina/http;
import ballerina/lang.runtime;
import ballerina/time;

class EventStream {
    private int count = 0;

    public isolated function next() returns record {|http:SseEvent value;|}|error? {
        self.count += 1;
        string timestamp = time:utcToString(time:utcNow()).substring(11, 19);
        http:SseEvent event = {data: string `message ${self.count} at ${timestamp}`};
        runtime:sleep(1);
        return {value: event};
    }
}

service / on new http:Listener(8000) {
    resource function get events() returns stream<http:SseEvent, error?> {
        return new stream<http:SseEvent, error?>(new EventStream());
    }

    resource function get .() returns json {
        return {"message": "SSE server running. Connect to /events"};
    }
}
