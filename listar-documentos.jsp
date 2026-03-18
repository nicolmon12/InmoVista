<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
/* ═══════════════════════════════════════════════════
   LISTAR-DOCUMENTOS.JSP — InmoVista
   Devuelve JSON con los documentos del cliente logueado.
   Respuesta: {"docs":[{nombre,tipo,fecha},...]}
═══════════════════════════════════════════════════ */

response.setHeader("Access-Control-Allow-Origin", "*");

String rol = (String) session.getAttribute("rolNombre");
if (!"cliente".equals(rol)) {
    out.print("{\"docs\":[]}");
    return;
}

int clienteId = 0;
Object uid = session.getAttribute("userId");
if (uid instanceof Integer) clienteId = (Integer) uid;
else if (uid != null) try { clienteId = Integer.parseInt(uid.toString()); } catch(Exception e){}

if (clienteId == 0) { out.print("{\"docs\":[]}"); return; }

StringBuilder json = new StringBuilder("{\"docs\":[");
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    java.sql.Connection db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db" +
        "?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true",
        "root", "");

    java.sql.PreparedStatement ps = db.prepareStatement(
        "SELECT nombre_archivo, tipo_doc, fecha_subida FROM documentos " +
        "WHERE cliente_id = ? ORDER BY fecha_subida DESC");
    ps.setInt(1, clienteId);
    java.sql.ResultSet rs = ps.executeQuery();

    boolean first = true;
    while (rs.next()) {
        if (!first) json.append(",");
        first = false;
        String nombre = rs.getString("nombre_archivo") != null ? rs.getString("nombre_archivo") : "";
        String tipo   = rs.getString("tipo_doc")       != null ? rs.getString("tipo_doc")       : "otro";
        String fecha  = rs.getString("fecha_subida")   != null ? rs.getString("fecha_subida").substring(0,10) : "";
        // escape
        nombre = nombre.replace("\\","\\\\").replace("\"","\\\"");
        json.append("{\"nombre\":\"").append(nombre).append("\",")
            .append("\"tipo\":\"").append(tipo).append("\",")
            .append("\"fecha\":\"").append(fecha).append("\"}");
    }
    rs.close(); ps.close(); db.close();

} catch (Exception e) {
    e.printStackTrace();
}
json.append("]}");
out.print(json.toString());
%>
