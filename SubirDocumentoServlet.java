package com.inmovista.servlets;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.nio.file.*;
import java.sql.*;

/**
 * SubirDocumentoServlet — maneja la subida y descarga de documentos del cliente.
 *
 * Configuración en web.xml (alternativa a anotaciones):
 *   <multipart-config>
 *     <max-file-size>5242880</max-file-size>       <!-- 5 MB -->
 *     <max-request-size>5242880</max-request-size>
 *   </multipart-config>
 */
@WebServlet("/SubirDocumentoServlet")
@MultipartConfig(
    maxFileSize    = 5 * 1024 * 1024,   // 5 MB por archivo
    maxRequestSize = 5 * 1024 * 1024    // 5 MB total
)
public class SubirDocumentoServlet extends HttpServlet {

    // Carpeta donde se guardan los archivos (fuera del webroot para seguridad)
    private static final String UPLOAD_DIR = "uploads_inmovista";

    // ── CONFIGURACIÓN BD ─────────────────────────────
    private static final String DB_URL  = "jdbc:mysql://localhost:3306/inmovista_db?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";
    // ─────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // Verificar sesión
        HttpSession session = req.getSession(false);
        if (session == null || !"cliente".equals(session.getAttribute("rolNombre"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int clienteId = (Integer) session.getAttribute("userId");

        // Obtener parámetros del formulario
        String tipoDoc        = getParam(req, "tipoDoc",        "otro");
        String propiedadTitulo= getParam(req, "propiedadTitulo","");
        String propIdStr      = getParam(req, "propiedadId",    "");
        Integer propiedadId   = null;
        try { if (!propIdStr.isEmpty()) propiedadId = Integer.parseInt(propIdStr); }
        catch (NumberFormatException ignored) {}

        // Obtener el archivo
        Part filePart = req.getPart("archivo");
        if (filePart == null || filePart.getSize() == 0) {
            redirigir(req, resp, "danger", "No se recibió ningún archivo.");
            return;
        }

        // Validar tipo de archivo
        String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String extension    = originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase()
                : "";
        if (!extension.matches("pdf|jpg|jpeg|png|doc|docx")) {
            redirigir(req, resp, "danger", "Tipo de archivo no permitido. Solo PDF, JPG, PNG, DOC.");
            return;
        }

        // Crear carpeta de destino
        String uploadPath = System.getProperty("user.home") + File.separator + UPLOAD_DIR
                + File.separator + clienteId;
        Files.createDirectories(Paths.get(uploadPath));

        // Nombre único para evitar colisiones
        String nombreUnico = System.currentTimeMillis() + "_" + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
        String rutaCompleta = uploadPath + File.separator + nombreUnico;

        // Guardar el archivo
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(rutaCompleta), StandardCopyOption.REPLACE_EXISTING);
        }

        // Guardar registro en BD
        try (Connection db = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            PreparedStatement ps = db.prepareStatement(
                "INSERT INTO documentos (cliente_id, propiedad_id, nombre_archivo, ruta_archivo, tipo_doc) " +
                "VALUES (?, ?, ?, ?, ?)");
            ps.setInt   (1, clienteId);
            if (propiedadId != null) ps.setInt(2, propiedadId); else ps.setNull(2, Types.INTEGER);
            ps.setString(3, originalName);
            ps.setString(4, rutaCompleta);
            ps.setString(5, tipoDoc);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            redirigir(req, resp, "danger", "Error al guardar en base de datos: " + e.getMessage());
            return;
        }

        redirigir(req, resp, "success", "✅ Documento subido exitosamente.");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Descarga de archivo
        String action = req.getParameter("action");
        if (!"descargar".equals(action)) { resp.sendError(400); return; }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");
        String rolNombre = (String) session.getAttribute("rolNombre");

        int docId;
        try { docId = Integer.parseInt(req.getParameter("id")); }
        catch (NumberFormatException e) { resp.sendError(400); return; }

        // Solo el propietario del documento o admin/inmobiliaria pueden descargarlo
        try (Connection db = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            PreparedStatement ps = db.prepareStatement(
                "SELECT nombre_archivo, ruta_archivo, cliente_id FROM documentos WHERE id = ?");
            ps.setInt(1, docId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { resp.sendError(404); return; }

            int clienteId    = rs.getInt("cliente_id");
            String nombreArch= rs.getString("nombre_archivo");
            String rutaArch  = rs.getString("ruta_archivo");

            // Verificar permisos
            boolean esAdmin = "admin".equals(rolNombre) || "inmobiliaria".equals(rolNombre);
            if (!esAdmin && clienteId != userId) { resp.sendError(403); return; }

            File archivo = new File(rutaArch);
            if (!archivo.exists()) { resp.sendError(404, "Archivo no encontrado en el servidor."); return; }

            // Determinar content type
            String ct = getServletContext().getMimeType(nombreArch);
            if (ct == null) ct = "application/octet-stream";

            resp.setContentType(ct);
            resp.setHeader("Content-Disposition", "inline; filename=\"" + nombreArch + "\"");
            resp.setContentLengthLong(archivo.length());

            try (InputStream in = new FileInputStream(archivo);
                 OutputStream out = resp.getOutputStream()) {
                byte[] buf = new byte[4096];
                int len;
                while ((len = in.read(buf)) > 0) out.write(buf, 0, len);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Error de base de datos.");
        }
    }

    private String getParam(HttpServletRequest req, String name, String def) {
        String val = req.getParameter(name);
        return (val != null && !val.isBlank()) ? val.trim() : def;
    }

    private void redirigir(HttpServletRequest req, HttpServletResponse resp,
                            String tipo, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/documentos.jsp"
                + "?flashType=" + tipo
                + "&flashMsg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
    }
}
