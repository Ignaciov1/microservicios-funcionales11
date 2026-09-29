#!/bin/bash
# ============================================
# EscolarOnline - Deploy contenedores en EC2
# Actividad 1.6 - Arquitectura Cloud ARY1102
# ============================================
# Ejecutar DENTRO de la instancia EC2 APP (via Session Manager)
# Prerequisitos: Docker instalado (user-data), acceso a ECR (LabRole)

# Variables - MODIFICAR con tus valores
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DB_HOST="10.0.2.X"  # <-- MODIFICAR: IP privada del EC2 MySQL

echo "=== Account ID: $ACCOUNT_ID ==="
echo "=== Region: $REGION ==="
echo "=== DB Host: $DB_HOST ==="

# Login en ECR desde EC2
echo "=== Autenticando en ECR ==="
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Pull imagenes desde ECR
echo "=== Descargando imagenes desde ECR ==="
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-frontend:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-get-products:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-create-product:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-update-product:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-delete-product:latest

# Detener contenedores existentes (si hay)
echo "=== Deteniendo contenedores existentes ==="
docker stop escolaronline-frontend escolaronline-get-products escolaronline-create-product escolaronline-update-product escolaronline-delete-product 2>/dev/null
docker rm escolaronline-frontend escolaronline-get-products escolaronline-create-product escolaronline-update-product escolaronline-delete-product 2>/dev/null

# Crear red Docker
docker network create escolaronline-net 2>/dev/null

# Ejecutar contenedores
echo "=== Levantando contenedores ==="

# GET Products
docker run -d --name escolaronline-get-products \
  --network escolaronline-net \
  -p 3001:3001 \
  -e DB_HOST=$DB_HOST \
  -e DB_USER=alumno \
  -e DB_PASS=alumno123 \
  -e DB_NAME=escolar_online \
  -e DB_PORT=3306 \
  -e PORT=3001 \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-get-products:latest

# CREATE Product
docker run -d --name escolaronline-create-product \
  --network escolaronline-net \
  -p 3002:3002 \
  -e DB_HOST=$DB_HOST \
  -e DB_USER=alumno \
  -e DB_PASS=alumno123 \
  -e DB_NAME=escolar_online \
  -e DB_PORT=3306 \
  -e PORT=3002 \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-create-product:latest

# UPDATE Product
docker run -d --name escolaronline-update-product \
  --network escolaronline-net \
  -p 3003:3003 \
  -e DB_HOST=$DB_HOST \
  -e DB_USER=alumno \
  -e DB_PASS=alumno123 \
  -e DB_NAME=escolar_online \
  -e DB_PORT=3306 \
  -e PORT=3003 \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-update-product:latest

# DELETE Product
docker run -d --name escolaronline-delete-product \
  --network escolaronline-net \
  -p 3004:3004 \
  -e DB_HOST=$DB_HOST \
  -e DB_USER=alumno \
  -e DB_PASS=alumno123 \
  -e DB_NAME=escolar_online \
  -e DB_PORT=3306 \
  -e PORT=3004 \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-delete-product:latest

# Frontend (Nginx)
docker run -d --name escolaronline-frontend \
  --network escolaronline-net \
  -p 80:80 \
  $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-frontend:latest

# Verificar contenedores
echo "=== Verificando contenedores ==="
docker ps

echo ""
echo "=== Deploy completado ==="
echo "=== Verificar acceso en: http://<IP-PUBLICA-EC2> ==="
echo "=== O via ALB DNS una vez configurado ==="

# 2026 - Disenador asignatura: Ignacio A. Pastenet M.
