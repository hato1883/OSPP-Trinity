# Load balancer Container

To configure the load balancer:

  * Edit `nginx.conf` to add backend nodes to balance to.
  * Restart nginx container: `docker compose restart lb`

Now you can visit [`localhost:8080`](http://localhost:8080) from your browser and should be forwarded to one of the nodes.
