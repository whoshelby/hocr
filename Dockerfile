FROM golang:1.21 AS build

WORKDIR /app

# Copy go mod and download deps
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build the Go binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o ocr-server main.go


# Final slim container
FROM debian:bookworm-slim

# Install tesseract
RUN apt-get update && \
    apt-get install -y tesseract-ocr tesseract-ocr-eng && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from build image
COPY --from=build /app/ocr-server /app/ocr-server

# Copy env file (optional)
COPY .env /app/.env

EXPOSE 8080

# Run server
CMD ["./ocr-server"]
