# Etapa de compilación
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar el archivo del proyecto desde la carpeta SchoolManager
COPY SchoolManager/SchoolManager.csproj ./SchoolManager/
WORKDIR /src/SchoolManager
RUN dotnet restore

# Copiar todo el contenido de SchoolManager
COPY SchoolManager/. .

# Publicar la aplicación
RUN dotnet publish -c Release -o /app/publish

# Etapa de runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .

# Variables de entorno para Render
ENV ASPNETCORE_URLS=http://+:10000
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 10000

ENTRYPOINT ["dotnet", "SchoolManager.dll"]
