-- ============================================
-- FreshBox SpA - Catálogo de Productos Orgánicos
-- Actividad 1.6 - Arquitectura Cloud ARY1102
-- ============================================

-- NOTA: Se mantiene el nombre de BD 'escolar_online' internamente
-- para garantizar la compatibilidad con los microservicios backend Node.js
CREATE DATABASE IF NOT EXISTS escolar_online DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE escolar_online;

-- Tabla de productos del catálogo online
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    categoria VARCHAR(100),
    imagen_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Datos de prueba iniciales para FreshBox SpA
INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Manzanas Fuji Orgánicas 1kg', 'Manzanas frescas cultivadas sin pesticidas, dulces y crujientes.', 2500.00, 100, 'Frutas'),
('Mix de Verduras de Temporada', 'Canasta con 5kg de verduras variadas directo del huerto local.', 12990.00, 45, 'Verduras'),
('Snack de Frutos Secos Premium 250g', 'Mix de almendras, nueces y maravillas sin sal ni aceites añadidos.', 4500.00, 200, 'Snacks'),
('Jugo Natural de Arándanos 1L', 'Jugo 100% natural prensado en frío, sin azúcar ni conservantes.', 3990.00, 60, 'Bebidas Naturales'),
('Miel de Abeja Pura 500g', 'Miel cruda de bosque nativo, extraída de forma sostenible.', 6500.00, 80, 'Despensa Orgánica');

-- 2026 - Diseño de Base de Datos Arquitectura Cloud