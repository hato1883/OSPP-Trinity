# Load Balancer

This module is designed to handle load balancing between multiple HTTP servers. It ensures efficient distribution of incoming requests to the available servers, improving performance and reliability.

See `../website-application/` for more information regarding the HTTP servers.

## Features

- Load balancing across multiple HTTP servers.
- Accessible via `http://localhost:8080`.

## Installation

1. Clone the repository:
    ```bash
    git clone <repository-url>
    ```

## Usage

1. Start the load balancer:
    ```bash
   docker compose up -d
    ```
2. Access the load balancer at:
    ```
    http://localhost:8080
    ```

## Configuration

You can configure the list of backend servers as well as rate limiting strategies etc. in the module's configuration file `haproxy.cfg`.


IF config is not loaded/updated on change try deleting the image and rebuilding it.
