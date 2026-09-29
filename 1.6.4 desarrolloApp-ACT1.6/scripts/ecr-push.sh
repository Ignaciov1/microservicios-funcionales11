#!/bin/bash
# ============================================
# EscolarOnline - Build y Push imagenes a ECR
# Actividad 1.6 - Arquitectura Cloud ARY1102
# ============================================
# Ejecutar desde la carpeta desarrolloapp/ en tu PC local
# Prerequisitos: Docker Desktop corriendo, AWS CLI configurado

# Variables - MODIFICAR con tus valores
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== Account ID: $ACCOUNT_ID ==="
echo "=== Region: $REGION ==="

# Login en ECR
echo "=== Autenticando en ECR ==="
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Crear repositorios ECR (si no existen)
echo "=== Creando repositorios ECR ==="
REPOS=("escolaronline-frontend" "escolaronline-get-products" "escolaronline-create-product" "escolaronline-update-product" "escolaronline-delete-product")

for REPO in "${REPOS[@]}"; do
    aws ecr create-repository --repository-name $REPO --region $REGION 2>/dev/null || echo "Repo $REPO ya existe"
done

# Build imagenes (ARM64 para t4g.micro Graviton)
echo "=== Construyendo imagenes Docker (ARM64) ==="
docker build --platform linux/arm64 -t escolaronline-frontend ./microservicioFrontend
docker build --platform linux/arm64 -t escolaronline-get-products ./microserviciosBackend/get-products
docker build --platform linux/arm64 -t escolaronline-create-product ./microserviciosBackend/create-product
docker build --platform linux/arm64 -t escolaronline-update-product ./microserviciosBackend/update-product
docker build --platform linux/arm64 -t escolaronline-delete-product ./microserviciosBackend/delete-product

# Tag imagenes
echo "=== Etiquetando imagenes ==="
docker tag escolaronline-frontend $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-frontend:latest
docker tag escolaronline-get-products $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-get-products:latest
docker tag escolaronline-create-product $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-create-product:latest
docker tag escolaronline-update-product $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-update-product:latest
docker tag escolaronline-delete-product $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-delete-product:latest

# Push imagenes a ECR
echo "=== Subiendo imagenes a ECR ==="
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-frontend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-get-products:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-create-product:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-update-product:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/escolaronline-delete-product:latest

echo "=== Push completado exitosamente ==="
echo "=== Imagenes disponibles en: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com ==="

# 2026 - Disenador asignatura: Ignacio A. Pastenet M.
