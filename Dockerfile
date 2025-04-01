# Elixir + Phoenix

FROM elixir:1.18.3

# Install debian packages
RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools postgresql-client

# Install Phoenix packages
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix hex phx_new

# Install node
#RUN curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
#RUN bash nodesource_setup.sh
RUN apt-get install --yes nodejs npm

WORKDIR /app
# Normal dev ports
EXPOSE 4000
EXPOSE 4001

# HTTP(S)
EXPOSE 80
EXPOSE 443
