# Hello

To start your Phoenix server:

  * Run `docker compose up` to install and setup server
  * If you get an error lookling like :
  ```
  unable to get image 'ospp-trinity-web': permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.48/images/ospp-trinity-web/json": dial unix /var/run/docker.sock: connect: permission denied
  ```
  Try running `sudo docker compose up`



Now you can visit [`localhost:8080`](http://localhost:8080) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

# Running a shell inside the container
Use `docker ps` to get the names of all running containers

To run a shell inside the container run `docker exec -it ospp-trinity-web-1 sh`. This is important for running `mix` commands

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
