package com.inmovista.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.sql.*;
import java.util.Properties;
import org.json.JSONObject;

/**
 * ContactoServlet — guarda sugerencias en BD Y las envía por Gmail.
 *
 * PASO 1 — Ejecutar en MySQL Workbench:
 *   USE inmobiliaria_db;
 *   CREATE TABLE IF NOT EXISTS sugerencias (
 *     id      INT NOT NULL AUTO_INCREMENT,
 *     nombre  VARCHAR(80)  NOT NULL,
 *     email   VARCHAR(120) NOT NULL,
 *     mensaje TEXT         NOT NULL,
 *     fecha   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
 *     PRIMARY KEY (id)
 *   ) ENGINE=InnoDB;
 *
 * PASO 2 — Cambiar GMAIL_USER y GMAIL_PASS (contraseña de aplicación de Google).
 *
 * PASO 3 — pom.xml:
 *   <dependency><groupId>com.sun.mail</groupId><artifactId>jakarta.mail</artifactId><version>2.0.1</version></dependency>
 *   <dependency><groupId>org.json</groupId><artifactId>json</artifactId><version>20231013</version></dependency>
 */
@WebServlet("/ContactoServlet")
public class ContactoServlet extends HttpServlet {

    // ── CONFIGURA AQUÍ ────────────────────────────────
    private static final String DB_URL  = "jdbc:mysql://localhost:3306/inmobiliaria_db"
        + "?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    private static final String GMAIL_USER   = "tucorreo@gmail.com";  // <-- tu Gmail
    private static final String GMAIL_PASS   = "xxxx xxxx xxxx xxxx"; // <-- contraseña de app
    private static final String DESTINATARIO = "tucorreo@gmail.com";  // <-- destinatario
    // ─────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");

        // Leer JSON del body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

        JSONObject json;
        try {
            json = new JSONObject(sb.toString());
        } catch (Exception e) {
            resp.getWriter().write("{\"ok\":false,\"error\":\"JSON invalido\"}");
            return;
        }

        String nombre  = json.optString("nombre",  "").trim();
        String email   = json.optString("email",   "").trim();
        String mensaje = json.optString("mensaje", "").trim();

        if (nombre.isEmpty() || email.isEmpty() || mensaje.isEmpty()) {
            resp.getWriter().write("{\"ok\":false,\"error\":\"Campos vacios\"}");
            return;
        }

        // 1. Guardar en BD (prioritario)
        boolean guardado = guardarEnBD(nombre, email, mensaje);

        // 2. Intentar email (no bloquea si falla)
        boolean emailOk = false;
        try { enviarEmail(nombre, email, mensaje); emailOk = true; }
        catch (Exception e) { System.err.println("Email no enviado: " + e.getMessage()); }

        if (guardado) {
            resp.getWriter().write("{\"ok\":true}");
        } else {
            resp.getWriter().write("{\"ok\":false,\"error\":\"Error al guardar en base de datos\"}");
        }
    }

    private boolean guardarEnBD(String nombre, String email, String mensaje) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection db = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                PreparedStatement ps = db.prepareStatement(
                    "INSERT INTO sugerencias (nombre, email, mensaje) VALUES (?, ?, ?)");
                ps.setString(1, nombre);
                ps.setString(2, email);
                ps.setString(3, mensaje);
                ps.executeUpdate();
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void enviarEmail(String nombre, String emailRemitente, String mensaje) throws Exception {
        if (GMAIL_USER.contains("tucorreo")) return; // no configurado aun

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        javax.mail.Session session = javax.mail.Session.getInstance(props,
            new javax.mail.Authenticator() {
                protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                    return new javax.mail.PasswordAuthentication(GMAIL_USER, GMAIL_PASS);
                }
            });

        javax.mail.Message msg = new javax.mail.internet.MimeMessage(session);
        msg.setFrom(new javax.mail.internet.InternetAddress(GMAIL_USER, "InmoVista Bot"));
        msg.setRecipients(javax.mail.Message.RecipientType.TO,
            javax.mail.internet.InternetAddress.parse(DESTINATARIO));
        msg.setSubject("Nueva sugerencia de " + nombre + " - InmoBot");

        String cuerpo = "<html><body style='font-family:Arial,sans-serif;'>"
            + "<div style='max-width:600px;margin:auto;border:1px solid #e0c96a;border-radius:12px;overflow:hidden;'>"
            + "<div style='background:#0d0d0d;padding:20px;text-align:center;'>"
            + "<h2 style='color:#c9a84c;margin:0;'>Nueva Sugerencia - InmoVista</h2></div>"
            + "<div style='padding:24px;background:#fff;'>"
            + "<p><strong>Nombre:</strong> " + escHtml(nombre) + "</p>"
            + "<p><strong>Correo:</strong> " + escHtml(emailRemitente) + "</p><hr>"
            + "<p><strong>Mensaje:</strong></p>"
            + "<p style='background:#f9f5e8;padding:14px;border-left:4px solid #c9a84c;'>" + escHtml(mensaje) + "</p>"
            + "</div></div></body></html>";

        msg.setContent(cuerpo, "text/html;charset=UTF-8");
        javax.mail.Transport.send(msg);
    }

    private String escHtml(String s) {
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}
