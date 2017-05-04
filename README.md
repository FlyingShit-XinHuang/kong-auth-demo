# Overview

This project implements a custom plugin of Kong to query an auth server to validate a JWT.

## Start Kong

### Build Kong image

The logs cannot be displayed with [official Docker image](https://hub.docker.com/_/kong/) 
when executing 'docker logs' command. So I wrap a run.sh to 'tail' the error.log. Build the 
image as following:

```
% docker build -t my-kong .
```

### Start containers

Start a Cassandra contaienr:

```
$ docker run -d --name kong-database -p 9042:9042 cassandra:3.10
```

Start a Kong container:

```
$ docker run -d --rm --name kong \
      --link kong-database:kong-database \
      -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
      -e "KONG_LOG_LEVEL=debug" \
      -p 8000:8000 \
      -p 8443:8443 \
      -p 8001:8001 \
      -p 7946:7946 \
      -p 7946:7946/udp \
      my-kong
```

## Run with plugin

### Start a resource server

After the Kong container started, the custom plugin has been already loaded. Run a resource
server that should be accessed with a token e.g. the main.go in this project:

```
$ go run main.go 
2017/04/28 15:42:24 listening 19000
```

### Register API and Enable plugin

Register the resource API:

```
$ curl -i -XPOST localhost:8001/apis/ \
    --data 'name=demo' --data 'upstream_url=http://<your server ip>:19000' --data 'uris=/demo'
```

Then the API could be queried with /demo path prefix:

```
$ curl localhost:8000/demo/foo
hello world
```

Enable the custom authorization plugin for this API with the auth server url specified by 
'auth_server_url' configuration:

```
$ curl -i -XPOST localhost:8001/apis/demo/plugins \
    --data 'name=whispir-token-auth' \
    --data 'config.auth_server_url=<URL of verification API>'
```

My another project 'auth-server' could be used as an auth server. The 'auth_server_url' could
be 'http://&lt;your server ip&gt;:18080/info'.

The resource API is protected now:

```
$ curl localhost:8000/demo/foo
{"message":"Missing token"}
```

Query the auth server to generate a token and query the resource API with the 'Authorization' 
header:

```
$ curl localhost:8000/demo/foo \
    -H "Authorization: bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0OTMzNzAwNjUsIm5iZiI6MTQ5MzM2NjQ2NSwiaWF0IjoxNDkzMzY2NDY1LCJjbGllbnRfaWQiOiI1Si1iMHRNclRGUzNBeExuckNmSDVBIn0.XUMUYMrrtKRKS11fVOvy4Vr4whS9ffRIxOQ_psSubwo"
hello world
```