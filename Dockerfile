#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:7.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
ADD ZscalerRootCertificate-2048-SHA256.crt /usr/local/share/ca-certificates/ZscalerRootCertificate-2048-SHA256.crt
RUN chmod 644 /usr/local/share/ca-certificates/ZscalerRootCertificate-2048-SHA256.crt && update-ca-certificates
COPY ["src/SimpleApp/SimpleApp.csproj", "src/SimpleApp/"]
RUN dotnet restore "src/SimpleApp/SimpleApp.csproj"
COPY . .
WORKDIR "/src/src/SimpleApp"
RUN dotnet build "SimpleApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SimpleApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SimpleApp.dll"]