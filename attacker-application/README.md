# Attacker Application

The `attacker-application` is a utility designed for testing and generating HTTP requests, as well as creating large JSON payloads for stress testing or other purposes. It includes modules for making GET and POST requests, generating JSON files, and interacting with external APIs.

# How to run
To run the attacker simply input: `elixir attack_token.ex` into the terminal while in the /lib directory. 

## Features

- **HTTP Requests**: Perform GET and POST requests to specified endpoints.
- **JSON Generation**: Generate large JSON files with random data for testing purposes.
- **External API Interaction**: Fetch data from external APIs, such as weather information.
- **Concurrency**: Spawn multiple processes to simulate concurrent requests.

## Modules


### `JsonGenerator`
Generates large JSON files with random data.

Example: 
```elixir
JsonGenerator.generate("output.json", 1_000_000)
```

### `get_request`
Handles HTTP GET requests to specified endpoints. This module allows users to send GET requests and retrieve responses, making it useful for testing APIs or fetching data from web services.

Example:
```elixir
GetRequest.perform("https://api.example.com/data")
```

### `attack_token`
Same as `get_request` but uses token or "IP" to identify each individual client.

## Slowloris

### How to run

## Preparations
Before running the program edit the second to last line in the program to set your preferences.
```
SlowLoris.start("https://api.exameple.com", <port>, <amount of concurrent requests>, <time in milliseconds inbetween each request>)
```
Note: Amount of concurrent requests maxes out at around 250 000 requests in its current state.

## Finally
To run the slowloris attack simply input: `elixir slowloris.ex` into the terminal while in the /lib directory. 

