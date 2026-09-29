# EscolarOnline — Aplicacion CRUD de Productos Escolares

## Descripcion

Aplicacion web CRUD (Crear, Leer, Modificar, Eliminar) de productos escolares construida con microservicios en contenedores Docker. Disenada para desplegarse en una arquitectura AWS de 3 capas con alta disponibilidad Multi-AZ.

## Arquitectura de la Aplicacion

| Contenedor | Funcion | Puerto | Endpoint | Runtime |
|------------|---------|--------|----------|---------|
| frontend | Interfaz web (Nginx) | 80 | / | Nginx Alpine |
| get-products | Consultar productos | 3001 | /api/products (GET) | Node.js 18 |
| create-product | Crear producto | 3002 | /api/products (POST) | Node.js 18 |
| update-product | Modificar producto | 3003 | /api/products/:id (PUT) | Node.js 18 |
| delete-product | Eliminar producto | 3004 | /api/products/:id (DELETE) | Node.js 18 |

## Estructura de Archivos

```
desarrolloApp-ACT1.6/
├── README.md                     (este archivo)
├── docker-compose.yml            (ejecucion local)
├── docker-compose.aws.yml        (ejecucion en EC2 con imagenes ECR)
├── init.sql                      (script BD + 5 productos de prueba)
├── microservicioFrontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── index.html
│   ├── css/styles.css
│   └── js/app.js
├── microserviciosBackend/
│   ├── get-products/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── index.js
│   ├── create-product/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── index.js
│   ├── update-product/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── index.js
│   └── delete-product/
│       ├── Dockerfile
│       ├── package.json
│       └── index.js
└── scripts/
    ├── user-data-ec2.sh          (bootstrap EC2: instala Docker + Compose)
    ├── ecr-push.sh               (build + push 5 imagenes a ECR)
    └── deploy-containers.sh      (pull ECR + docker compose up en EC2)
```

## Variables de Entorno

| Variable | Descripcion | Valor local | Valor AWS |
|----------|-------------|-------------|-----------|
| DB_HOST | Host de MySQL | db | (IP privada EC2 MySQL) |
| DB_USER | Usuario BD | alumno | alumno |
| DB_PASS | Password BD | alumno123 | alumno123 |
| DB_NAME | Nombre BD | escolar_online | escolar_online |
| DB_PORT | Puerto BD | 3306 | 3306 |

## Datos de Prueba (init.sql)

La base de datos se inicializa con 5 productos escolares:
1. Cuaderno universitario 100 hojas
2. Mochila escolar reforzada
3. Set 12 lapices de colores
4. Calculadora cientifica
5. Estuche escolar doble cierre

---

# PARTE 1: EJECUCION LOCAL

Todo lo necesario para validar la aplicacion en tu PC antes de subir a AWS.

## Requisitos Previos (Local)

- Docker Desktop instalado y corriendo
- Docker Compose v2+
- Navegador web
- Terminal (PowerShell o CMD)

## Paso 1: Navegar al proyecto

```bash
cd desarrolloApp-ACT1.6
```

## Paso 2: Construir y levantar contenedores

```bash
docker compose build
docker compose up -d
```

## Paso 3: Verificar que los contenedores estan corriendo

```bash
docker compose ps
```

Resultado esperado: 6 servicios (db, frontend, get-products, create-product, update-product, delete-product) en estado "running".

## Paso 4: Verificar base de datos

```bash
docker exec -it escolaronline-db mysql -u alumno -palumno123 -e "SELECT * FROM escolar_online.productos;"
```

Resultado esperado: tabla con 5 productos escolares.

## Paso 5: Probar desde el navegador

| URL | Resultado esperado |
|-----|-------------------|
| http://localhost:8080 | Frontend web con tabla de productos y formulario CRUD |
| http://localhost:3001/api/products | JSON con listado de 5 productos |
| http://localhost:3001/health | JSON {"status":"OK","service":"get-products"} |

## Paso 6: Pruebas CRUD por terminal

### Opcion A: PowerShell (Windows)

```powershell
# GET - Listar todos los productos
Invoke-RestMethod http://localhost:3001/api/products

# GET - Obtener producto por ID
Invoke-RestMethod http://localhost:3001/api/products/1

# POST - Crear nuevo producto
Invoke-RestMethod -Method POST -Uri http://localhost:3002/api/products -ContentType "application/json" -Body '{"nombre":"Goma borrar","descripcion":"Goma blanca","precio":590,"stock":100,"categoria":"Escritura"}'

# PUT - Modificar producto (ID 1)
Invoke-RestMethod -Method PUT -Uri http://localhost:3003/api/products/1 -ContentType "application/json" -Body '{"nombre":"Cuaderno 200 hojas","descripcion":"Cuaderno grande tapa dura","precio":3990,"stock":100,"categoria":"Cuadernos"}'

# DELETE - Eliminar producto (ID 6)
Invoke-RestMethod -Method DELETE -Uri http://localhost:3004/api/products/6

# Health checks
Invoke-RestMethod http://localhost:3001/health
Invoke-RestMethod http://localhost:3002/health
Invoke-RestMethod http://localhost:3003/health
Invoke-RestMethod http://localhost:3004/health
```

### Opcion B: CMD (Windows)

```cmd
:: GET - Listar todos los productos
curl http://localhost:3001/api/products

:: GET - Obtener producto por ID
curl http://localhost:3001/api/products/1

:: POST - Crear nuevo producto
curl -X POST http://localhost:3002/api/products -H "Content-Type: application/json" -d "{\"nombre\":\"Goma borrar\",\"descripcion\":\"Goma blanca\",\"precio\":590,\"stock\":100,\"categoria\":\"Escritura\"}"

:: PUT - Modificar producto (ID 1)
curl -X PUT http://localhost:3003/api/products/1 -H "Content-Type: application/json" -d "{\"nombre\":\"Cuaderno 200 hojas\",\"descripcion\":\"Cuaderno grande tapa dura\",\"precio\":3990,\"stock\":100,\"categoria\":\"Cuadernos\"}"

:: DELETE - Eliminar producto (ID 6)
curl -X DELETE http://localhost:3004/api/products/6

:: Health checks
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health
```

## Respuestas Esperadas (Local)

| Operacion | Endpoint | Respuesta esperada |
|-----------|----------|-------------------|
| GET all | localhost:3001/api/products | JSON array con 5 productos |
| GET by ID | localhost:3001/api/products/1 | JSON objeto con producto ID 1 |
| POST | localhost:3002/api/products | JSON producto creado (status 201) |
| PUT | localhost:3003/api/products/1 | JSON producto actualizado (status 200) |
| DELETE | localhost:3004/api/products/6 | JSON mensaje "Producto eliminado correctamente" |
| Health | localhost:3001/health | JSON {"status":"OK","service":"get-products","port":"3001"} |

## Paso 7: Detener contenedores

```bash
docker compose down
```

Para reiniciar desde cero (eliminar BD y recrear):

```bash
docker compose down -v
docker compose build
docker compose up -d
```

---

# PARTE 2: DESPLIEGUE EN AWS

Una vez validada la aplicacion localmente, se despliega en AWS Academy siguiendo la arquitectura de 3 capas Multi-AZ.

## Requisitos Previos (AWS)

- AWS Academy Learner Lab activo
- AWS CLI configurado con credenciales del lab
- Docker Desktop corriendo (para build de imagenes ARM64)
- Acceso a consola AWS
- Navegador web

## Arquitectura AWS (3 Capas - Multi-AZ)

| Capa | Componente | AZ | Tipo instancia |
|------|-----------|-----|----------------|
| Publica | ALB | AZ1a + AZ1b | - |
| Privada APP | EC2 APP-1 + Docker (5 contenedores) | AZ1a | t4g.micro |
| Privada APP | EC2 APP-2 + Docker (5 contenedores) | AZ1b | t4g.micro |
| Privada DATA | EC2 MySQL | AZ1a | t4g.micro |
| DR | AWS Backup (snapshot EC2 MySQL) | AZ1b | - |

## Resumen de Pasos AWS

| Paso | Accion | Donde |
|------|--------|-------|
| 1 | Crear VPC Multi-AZ (10.0.0.0/22) + subredes + IGW + NAT GW | Consola AWS |
| 2 | Crear Security Groups (SG-ALB, SG-APP, SG-DATA) | Consola AWS |
| 3 | Crear EC2 MySQL (t4g.micro) en subred privada DATA AZ1a | Consola AWS |
| 4 | Conectar a EC2 MySQL y ejecutar init.sql | Session Manager |
| 5 | Configurar AWS Backup para EC2 MySQL (DR a AZ1b) | Consola AWS |
| 6 | Crear EC2 APP-1 (t4g.micro) en subred privada APP AZ1a | Consola AWS |
| 7 | Crear EC2 APP-2 (t4g.micro) en subred privada APP AZ1b | Consola AWS |
| 8 | Crear 5 repositorios ECR | Consola AWS / CLI |
| 9 | Build y push 5 imagenes Docker a ECR (ARM64) | PC local |
| 10 | Deploy contenedores en EC2 APP-1 (docker compose) | Session Manager |
| 11 | Deploy contenedores en EC2 APP-2 (docker compose) | Session Manager |
| 12 | Crear ALB + Target Group (registrar ambas EC2 APP) | Consola AWS |
| 13 | Validar CRUD funcional via DNS del ALB | Navegador / curl |

**Guia detallada:** Consultar **Act-1.6-Anexo-Paso-a-Paso-Implementacion.md**

## Pruebas CRUD en AWS

Reemplazar `<ALB-DNS>` con el DNS real del Application Load Balancer.

### Desde AWS CloudShell o Linux

```bash
# GET - Listar todos los productos
curl http://<ALB-DNS>:3001/api/products

# POST - Crear nuevo producto
curl -X POST http://<ALB-DNS>:3002/api/products \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Goma borrar","descripcion":"Goma blanca","precio":590,"stock":100,"categoria":"Escritura"}'

# PUT - Modificar producto (ID 1)
curl -X PUT http://<ALB-DNS>:3003/api/products/1 \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Cuaderno 200 hojas","descripcion":"Grande","precio":3990,"stock":100,"categoria":"Cuadernos"}'

# DELETE - Eliminar producto (ID 6)
curl -X DELETE http://<ALB-DNS>:3004/api/products/6
```

### Desde el navegador

| URL | Resultado esperado |
|-----|-------------------|
| http://<ALB-DNS> | Frontend web con tabla de productos |
| http://<ALB-DNS>:3001/api/products | JSON con listado de productos |

## Checklist de Validacion AWS

- [ ] VPC con 6 subredes (2 pub + 2 priv APP + 2 priv DATA)
- [ ] 3 Security Groups configurados (SG-ALB, SG-APP, SG-DATA)
- [ ] EC2 MySQL con BD poblada (5 productos)
- [ ] AWS Backup configurado para EC2 MySQL
- [ ] EC2 APP-1 con 5 contenedores corriendo (docker ps)
- [ ] EC2 APP-2 con 5 contenedores corriendo (docker ps)
- [ ] ALB activo con 2 targets healthy
- [ ] GET productos funcional via ALB
- [ ] POST crear producto funcional via ALB
- [ ] PUT modificar producto funcional via ALB
- [ ] DELETE eliminar producto funcional via ALB
- [ ] Frontend accesible via ALB

---

2026 - Disenador asignatura: Ignacio A. Pastenet M.
