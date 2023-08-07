FROM golang:1.16-alpine
WORKDIR /app
COPY go.mod go.sum ./
COPY app.go .
RUN go mod download
RUN go build -o app
ENTRYPOINT ["./app"]
EXPOSE 8080

