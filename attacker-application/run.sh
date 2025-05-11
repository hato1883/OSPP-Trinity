RAND_NAME=$(mktemp -u XXXXXX | tr '[:upper:]' '[:lower:]')

iex --sname $RAND_NAME --cookie HARALD -S mix run