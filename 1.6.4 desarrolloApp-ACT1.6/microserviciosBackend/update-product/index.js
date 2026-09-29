const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3003;

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'alumno',
  password: process.env.DB_PASS || 'alumno123',
  database: process.env.DB_NAME || 'escolar_online',
  port: process.env.DB_PORT || 3306
};

// PUT /api/products/:id - Modificar producto existente
app.put('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, descripcion, precio, stock, categoria } = req.body;

    // Validacion de campos obligatorios
    if (!nombre || !precio || stock === undefined) {
      return res.status(400).json({ error: 'Campos obligatorios: nombre, precio, stock' });
    }

    if (precio <= 0) {
      return res.status(400).json({ error: 'El precio debe ser mayor a 0' });
    }

    const connection = await mysql.createConnection(dbConfig);

    // Verificar que el producto existe
    const [existing] = await connection.execute('SELECT * FROM productos WHERE id = ?', [id]);
    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    // Actualizar producto
    await connection.execute(
      'UPDATE productos SET nombre = ?, descripcion = ?, precio = ?, stock = ?, categoria = ? WHERE id = ?',
      [nombre, descripcion || null, precio, stock, categoria || null, id]
    );

    const [updated] = await connection.execute('SELECT * FROM productos WHERE id = ?', [id]);
    await connection.end();

    res.json(updated[0]);
  } catch (error) {
    console.error('Error al modificar producto:', error.message);
    res.status(500).json({ error: 'Error al modificar producto', detalle: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'update-product', port: PORT });
});

app.listen(PORT, () => {
  console.log(`[update-product] Servicio corriendo en puerto ${PORT}`);
});

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
