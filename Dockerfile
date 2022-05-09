FROM mcr.microsoft.com/dotnet/aspnet:6.0
COPY app/ /app
COPY ascii/ /app/ascii/
WORKDIR /app
EXPOSE 80
ENTRYPOINT ["dotnet", "loco-logo.dll"]