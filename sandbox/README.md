# Sandbox

Basic example for a TCP load balancer. By default it listens for connections on port 8083 and forwards the traffic to 127.0.0.1:80. It is currently set to use one worker pair where one worker forwards incoming data to the server, and the other forwards the server response to the client.

These settings can be altered in the lib/sandbox/application.ex file. If multiple servers are configured for the load balancer the connections will be distributed using round robin.

This requires some form of server listening on port 80 on the same host running the load balancer. I simply installed nginx which sets up an http server by default.

To run the application use `mix run`

Then use the browser and navigate to 127.0.0.1:8083 (or localhost:8083) and you should see whatever the http server is responding with.

Note that if the http server sets the `Connection` header to `keep-alive` this will occupy the workers for however long the connection remains open, and new requests will not be handled until the connection closes.

This example does not have much error handling, nor will the TcpSupervisor restart crashed workers as it is just a proof of concept.