#!/bin/bash

# restore dependencies
dotnet restore

# build release
dotnet build -c release --no-restore

# publish
dotnet publish -o app

# build docker image
docker build . -t loco-logo

exit 0