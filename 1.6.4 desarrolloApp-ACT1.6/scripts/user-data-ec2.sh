#!/bin/bash
# ============================================
# EscolarOnline - User Data para EC2 APP
# Actividad 1.6 - Arquitectura Cloud ARY1102
# ============================================
# Este script se ejecuta automaticamente al lanzar la instancia EC2
# Instala Docker, Docker Compose y herramientas necesarias

# Log de user data
sudo exec > /var/log/user-data.log 2>&1
sudo set -x

# Actualizar paquetes e instalar Docker (Amazon Linux 2023)
sudo yum update -y
sudo yum install -y docker

# Habilitar y arrancar Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
sudo newgrp docker

# Instalar Docker Compose v2
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-aarch64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verificar instalacion
docker --version
docker compose version

# Instalar herramientas adicionales
sudo yum install -y telnet
sudo yum install -y mysql

# Instalar AWS CLI (ya viene en Amazon Linux 2023)
aws --version

echo "=== User Data completado exitosamente ==="

# 2026 - Disenador asignatura: Ignacio A. Pastenet M.
