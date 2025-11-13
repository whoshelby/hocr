# -------------------------------
# Build Stage
# -------------------------------
FROM golang:1.21 AS build

RUN apt-get update && \
    apt-get install -y \
        libleptonica-dev \
        libtesseract-dev \
        tesseract-ocr \
        tesseract-ocr-eng && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=1 go build -o ocr-server main.go


# -------------------------------
# Runtime Stage
# -------------------------------
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
        tesseract-ocr \
        tesseract-ocr-eng \
        libtesseract-dev \
        libleptonica-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/ocr-server /app/ocr-server
COPY .env /app/.env

EXPOSE 8080

CMD ["./ocr-server"]
