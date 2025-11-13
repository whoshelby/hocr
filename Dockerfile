# -------------------------------
# Build Stage
# -------------------------------
FROM golang:1.21 as build

# Install build dependencies for gosseract
RUN apt-get update && \
    apt-get install -y \
        libleptonica-dev \
        libtesseract-dev \
        tesseract-ocr \
        tesseract-ocr-eng && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy go.mod first to cache modules
COPY go.mod go.sum ./
RUN go mod download

# Copy all source code
COPY . .

# Build the Go binary with CGO enabled
RUN CGO_ENABLED=1 go build -o ocr-server main.go


# -------------------------------
# Runtime Stage (Slim)
# -------------------------------
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y \
        tesseract-ocr \
        tesseract-ocr-eng && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary
COPY --from=build /app/ocr-server /app/ocr-server
COPY .env /app/.env

EXPOSE 8080

CMD ["./ocr-server"]
