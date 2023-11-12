# builds the Golang main.go for Linux environments

# build the binary
build:
	go build -o health-check main.go

build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o health-check main.go