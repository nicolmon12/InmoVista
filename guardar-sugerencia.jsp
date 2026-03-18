<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
response.setHeader("Access-Control-Allow-Origin","*");
response.setHeader("Access-Control-Allow-Methods","POST,OPTIONS");
response.setHeader("Access-Control-Allow-Headers","Content-Type");

if("OPTIONS".equalsIgnoreCase(request.getMethod())){response.setStatus(200);return;}

// Leer body completo
java.io.BufferedReader br = request.getReader();
StringBuilder sb = new StringBuilder();
String line;
while((line=br.readLine())!=null) sb.append(line);
String body = sb.toString();

// Extraer campos del JSON manualmente
String nombre  = campo(body,"nombre");
String email   = campo(body,"email");
String mensaje = campo(body,"mensaje");

if(nombre.isEmpty()||email.isEmpty()||mensaje.isEmpty()){
  out.print("{\"ok\":false,\"error\":\"Campos vacios: n="+nombre+" e="+email+"\"}");
  return;
}

// Guardar en BD
try{
  Class.forName("com.mysql.cj.jdbc.Driver");
  java.sql.Connection db = java.sql.DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/inmobiliaria_db?useSSL=false&serverTimezone=America/Bogota&allowPublicKeyRetrieval=true",
    "root","");
  java.sql.PreparedStatement ps = db.prepareStatement(
    "INSERT INTO sugerencias(nombre,email,mensaje) VALUES(?,?,?)");
  ps.setString(1,nombre);
  ps.setString(2,email);
  ps.setString(3,mensaje);
  ps.executeUpdate();
  ps.close();
  db.close();
  out.print("{\"ok\":true}");
}catch(Exception e){
  out.print("{\"ok\":false,\"error\":\""+e.getMessage().replace("\"","'").replace("\n"," ")+"\"}");
}
%><%!
private String campo(String json,String key){
  try{
    int i=json.indexOf("\""+key+"\"");
    if(i<0)return"";
    i=json.indexOf(":",i)+1;
    while(i<json.length()&&(json.charAt(i)==' '||json.charAt(i)=='\t'))i++;
    if(i>=json.length()||json.charAt(i)!='"')return"";
    i++;
    StringBuilder v=new StringBuilder();
    while(i<json.length()&&json.charAt(i)!='"'){
      if(json.charAt(i)=='\\')i++;
      if(i<json.length())v.append(json.charAt(i));
      i++;
    }
    return v.toString().trim();
  }catch(Exception e){return"";}
}
%>
