const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3001;

// Configuracion de conexion a MySQL
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'alumno',
  password: process.env.DB_PASS || 'alumno123',
  database: process.env.DB_NAME || 'escolar_online',
  port: process.env.DB_PORT || 3306
};

// GET /api/products - Listar todos los productos
app.get('/api/products', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT * FROM productos ORDER BY id DESC');
    await connection.end();
    res.json(rows);
  } catch (error) {
    console.error('Error al consultar productos:', error.message);
    res.status(500).json({ error: 'Error al consultar productos', detalle: error.message });
  }
});

// GET /api/products/:id - Obtener producto por ID
app.get('/api/products/:id', async (req, res) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute('SELECT * FROM productos WHERE id = ?', [req.params.id]);
    await connection.end();
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }
    res.json(rows[0]);
  } catch (error) {
    console.error('Error al consultar producto:', error.message);
    res.status(500).json({ error: 'Error al consultar producto', detalle: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'get-products', port: PORT });
});

app.listen(PORT, () => {
  console.log(`[get-products] Servicio corriendo en puerto ${PORT}`);
});

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
