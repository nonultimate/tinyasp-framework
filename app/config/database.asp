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
 */
CONFIG["db"] = {
  "default": {
    "driver":   "{Microsoft Access Driver (*.mdb)}",
    "database": "app\\data\\db.mdb",
    "user":     "admin",
    "password": "manager"
  }
}
%>