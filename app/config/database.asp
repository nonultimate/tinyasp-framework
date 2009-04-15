<%
/**
 * ODBC drivers:
 * Access:     {Microsoft Access Driver (*.mdb)}
 * SQL Server: {SQL Server}
 * MySQL:      {MySQL ODBC 3.51 Driver}
 *             {MySQL ODBC 5.1 Driver}
 * PostgreSQL: {PostgreSQL ANSI}
 *             {PostgreSQL Unicode}
 * SQLite:     {SQLite ODBC Driver}
 *             {SQLite3 ODBC Driver}
 * Oracle XE:  {Oracle in XE}
 * Oracle:     {Oracle ODBC Driver}
 */
// Database configuration
CONFIG["db"] = {
  "default": {
    "driver":   "{SQL Server}",
    "server":   ".\\SQLEXPRESS",
    "user":     "admin",
    "password": "manager",
    "database": "test",
    "charset":  "utf8"
  }
}
%>