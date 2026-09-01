# syntax=docker/dockerfile:1
#
# evaluation-service (Go) — o "hot path". Build multi-stage, imagem final distroless.
# É o serviço que sofre o teste de carga do HPA, então o binário é estático e a
# imagem não carrega nada além dele.

# ---------- estágio 1: build ----------
FROM golang:1.21-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath -ldflags="-s -w" \
    -o /out/evaluation-service .

# ---------- estágio 2: runtime ----------
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /out/evaluation-service /evaluation-service

EXPOSE 8004
USER nonroot:nonroot

ENTRYPOINT ["/evaluation-service"]
