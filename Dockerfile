FROM golang:1.23-alpine AS build
  WORKDIR /app
  COPY server.go go.mod ./
  RUN go build -ldflags="-s -w" -o server server.go
  FROM alpine:latest
  RUN apk --no-cache add ca-certificates
  WORKDIR /app
  COPY --from=build /app/server .
  EXPOSE 8080
  CMD ["./server"]
  