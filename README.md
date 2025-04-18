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

# Updating the Phoenix build

If you update the build in any way by using a `mix` command. Remember that you will also have to run `mix deps.get` and `mix ecto.migrate` to rebuild your dependencies and migrate the database respectively.  

# Updating file permissions

If you run any command that generates files from within a container, the files generated may have different permissions and won't be editable from your machine. Fix this by running `sudo chown -R $(whoami):$(whoami) ./` to recursively change the permissions to your current user throughout the entire directory.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
