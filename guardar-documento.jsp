<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
response.setHeader("Access-Control-Allow-Origin","*");

String rol = (String) session.getAttribute("rolNombre");
if (!"cliente".equals(rol)) { out.print("{\"ok\":false,\"error\":\"No autorizado\"}"); return; }

int clienteId = 0;
Object uid = session.getAttribute("userId");
if (uid instanceof Integer) clienteId = (Integer) uid;
else if (uid != null) try { clienteId = Integer.parseInt(uid.toString()); } catch(Exception e){}
if (clienteId == 0) { out.print("{\"ok\":false,\"error\":\"Sesion invalida\"}"); return; }

// Leer parámetros normales (sin multipart)
String tipoDoc    = request.getParameter("tipoDoc");
String propiedad  = request.getParameter("propiedadTitulo");
String nombreArch = request.getParameter("nombreArchivo");

if (tipoDoc == null || tipoDoc.isEmpty()) tipoDoc = "otro";
if (propiedad == null) propiedad = "";
if (nombreArch == null || nombreArch.isEmpty()) nombreArch = "documento";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    java.sql.Connection db = java.sql.DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true",
        "root", "");
    java.sql.PreparedStatement ps = db.prepareStatement(
        "INSERT INTO documentos (cliente_id, nombre_archivo, ruta_archivo, tipo_doc) VALUES (?,?,?,?)");
    ps.setInt(1, clienteId);
    ps.setString(2, nombreArch);
    ps.setString(3, "pendiente_de_envio_fisico");
    ps.setString(4, tipoDoc);
    ps.executeUpdate();
    ps.close(); db.close();
    out.print("{\"ok\":true}");
} catch(Exception e) {
    e.printStackTrace();
    out.print("{\"ok\":false,\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
}
%>
