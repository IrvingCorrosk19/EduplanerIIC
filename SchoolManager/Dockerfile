# Usar la imagen base de .NET SDK para compilar
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar archivos de proyecto y restaurar dependencias
COPY ["SchoolManager.csproj", "SchoolManager.sln", "./"]
COPY ["libman.json", "./"]
RUN dotnet restore

# Copiar el resto del código fuente
COPY . .

# Publicar la aplicación
RUN dotnet publish "SchoolManager.csproj" -c Release -o /app/publish --no-restore

# Construir la imagen final de runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Instalar dependencias del sistema para PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar la aplicación publicada
COPY --from=build /app/publish .

# Crear directorio para uploads
RUN mkdir -p /app/wwwroot/uploads && \
    chmod 755 /app/wwwroot/uploads

# Configurar las variables de entorno
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_RUNNING_IN_CONTAINER=true

# Exponer el puerto
EXPOSE 8080

# Configurar el punto de entrada
ENTRYPOINT ["dotnet", "SchoolManager.dll"] 