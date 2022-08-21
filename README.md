# Example Micro-service


![CI/CD status](https://github.com/pensive-lake-recruiting/example/actions/workflows/services.example.yml/badge.svg)
[API](https://pensive-lake-recruiting.github.io/example/)

## Build & Test

To build a container image and run tests, simply run `make`.
To run in docker, run `docker-compose up`
Then open a different terminal to test it via `curl`, i.e.:

```bash
curl localhost:8080/health
curl localhost:8080/ready
```
