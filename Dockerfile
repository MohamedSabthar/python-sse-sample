FROM ballerina/ballerina:2201.13.1 AS ballerina-build

USER root

COPY . /home/work-dir/service
WORKDIR /home/work-dir/service

RUN bal build

FROM ballerina/jvm-runtime:3.0

RUN addgroup troupe \
    && adduser -S -s /bin/bash -g 'ballerina' -G troupe -D ballerina \
    && apk add --update --no-cache bash \
    && apk upgrade --no-cache libcrypto3 libssl3 \
    && rm -rf /var/cache/apk/*

USER 10001

WORKDIR /home/work-dir/

COPY --from=ballerina-build /home/work-dir/service/target/bin/sse.jar /home/work-dir/

EXPOSE 8000

CMD java -jar sse.jar
