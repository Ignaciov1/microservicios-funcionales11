const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3004;

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'alumno',
  password: process.env.DB_PASS || 'alumno123',
  database: process.env.DB_NAME || 'escolar_online',
  port: process.env.DB_PORT || 3306
};

// DELETE /api/products/:id - Eliminar producto
app.delete('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const connection = await mysql.createConnection(dbConfig);

    // Verificar que el producto existe
    const [existing] = await connection.execute('SELECT * FROM productos WHERE id = ?', [id]);
    if (existing.length === 0) {
      await connection.end();
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    // Eliminar producto
    await connection.execute('DELETE FROM productos WHERE id = ?', [id]);
    await connection.end();

    res.json({ message: 'Producto eliminado correctamente', id: parseInt(id) });
  } catch (error) {
    console.error('Error al eliminar producto:', error.message);
    res.status(500).json({ error: 'Error al eliminar producto', detalle: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'delete-product', port: PORT });
});

app.listen(PORT, () => {
  console.log(`[delete-product] Servicio corriendo en puerto ${PORT}`);
});

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
