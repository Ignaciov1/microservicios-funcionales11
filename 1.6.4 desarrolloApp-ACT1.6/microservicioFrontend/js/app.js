// EscolarOnline - Logica Frontend CRUD
// Actividad 1.6 - ARY1102 Arquitectura Cloud

// Configuracion de URLs de los microservicios
// En local: usar localhost con puertos directos
// En AWS: usar la IP/DNS del ALB (puerto 80, Nginx rutea internamente)
const API_BASE = window.location.hostname === 'localhost' 
    ? 'http://localhost' 
    : window.location.origin;

const API_GET = '/api/products';
const API_POST = '/api/products';
const API_PUT = '/api/products';
const API_DELETE = '/api/products';

// Cargar productos al iniciar
document.addEventListener('DOMContentLoaded', cargarProductos);

// GET - Cargar todos los productos
async function cargarProductos() {
    try {
        const response = await fetch(API_GET);
        if (!response.ok) throw new Error('Error al cargar productos');
        const productos = await response.json();
        renderizarTabla(productos);
        mostrarMensaje('Productos cargados correctamente', 'exito');
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje('Error al cargar productos: ' + error.message, 'error');
    }
}

// Renderizar tabla de productos
function renderizarTabla(productos) {
    const tbody = document.getElementById('productos-body');
    tbody.innerHTML = '';

    if (productos.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7">No hay productos registrados</td></tr>';
        return;
    }

    productos.forEach(producto => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${producto.id}</td>
            <td>${producto.nombre}</td>
            <td>${producto.descripcion || '-'}</td>
            <td>$${Number(producto.precio).toLocaleString('es-CL')}</td>
            <td>${producto.stock}</td>
            <td>${producto.categoria || '-'}</td>
            <td>
                <button class="btn-editar" onclick="editarProducto(${producto.id}, '${escapar(producto.nombre)}', '${escapar(producto.descripcion || '')}', ${producto.precio}, ${producto.stock}, '${escapar(producto.categoria || '')}')">Editar</button>
                <button class="btn-eliminar" onclick="eliminarProducto(${producto.id})">Eliminar</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

// POST/PUT - Guardar producto (crear o modificar)
async function guardarProducto(event) {
    event.preventDefault();

    const id = document.getElementById('producto-id').value;
    const datos = {
        nombre: document.getElementById('nombre').value,
        descripcion: document.getElementById('descripcion').value,
        precio: parseFloat(document.getElementById('precio').value),
        stock: parseInt(document.getElementById('stock').value),
        categoria: document.getElementById('categoria').value
    };

    try {
        let response;
        if (id) {
            // PUT - Modificar
            response = await fetch(API_PUT + '/' + id, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(datos)
            });
        } else {
            // POST - Crear
            response = await fetch(API_POST, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(datos)
            });
        }

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Error al guardar');
        }

        mostrarMensaje(id ? 'Producto modificado correctamente' : 'Producto creado correctamente', 'exito');
        limpiarFormulario();
        cargarProductos();
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje('Error: ' + error.message, 'error');
    }
}

// DELETE - Eliminar producto
async function eliminarProducto(id) {
    if (!confirm('Estas seguro de eliminar este producto?')) return;

    try {
        const response = await fetch(API_DELETE + '/' + id, {
            method: 'DELETE'
        });

        if (!response.ok) throw new Error('Error al eliminar');

        mostrarMensaje('Producto eliminado correctamente', 'exito');
        cargarProductos();
    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje('Error al eliminar: ' + error.message, 'error');
    }
}

// Cargar datos en formulario para editar
function editarProducto(id, nombre, descripcion, precio, stock, categoria) {
    document.getElementById('producto-id').value = id;
    document.getElementById('nombre').value = nombre;
    document.getElementById('descripcion').value = descripcion;
    document.getElementById('precio').value = precio;
    document.getElementById('stock').value = stock;
    document.getElementById('categoria').value = categoria;
    document.getElementById('form-titulo').textContent = 'Editar Producto (ID: ' + id + ')';
    document.getElementById('btn-guardar').textContent = 'Actualizar';
}

// Cancelar edicion
function cancelarEdicion() {
    limpiarFormulario();
}

// Limpiar formulario
function limpiarFormulario() {
    document.getElementById('producto-form').reset();
    document.getElementById('producto-id').value = '';
    document.getElementById('form-titulo').textContent = 'Nuevo Producto';
    document.getElementById('btn-guardar').textContent = 'Guardar';
}

// Mostrar mensaje
function mostrarMensaje(texto, tipo) {
    const msg = document.getElementById('mensaje');
    msg.textContent = texto;
    msg.className = tipo === 'exito' ? 'mensaje-exito' : 'mensaje-error';
    setTimeout(() => { msg.textContent = ''; msg.className = ''; }, 4000);
}

// Escapar caracteres especiales para HTML
function escapar(str) {
    return str.replace(/'/g, "\\'").replace(/"/g, '\\"');
}

// 2026 - Disenador asignatura: Ignacio A. Pastenet M.
