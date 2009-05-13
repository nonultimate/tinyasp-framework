<%
/**
 * Tinyasp Framework
 *
 * This source file is subject to the new BSD license that is bundled
 * with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://tinyasp.org/license/LICENSE.txt
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to nonultimate@gmail.com so we can send you a copy immediately.
 *
 * @package   Model
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "db\\db.asp"));

$.Model = function(base) {

  /**
   * Database configuration name
   */
  this.db = "";

  /**
   * Database type
   */
  this.type = "";

  /**
   * Table name
   */
  this.table = "";

  /**
   * Primary key
   */
  this.pkey = "";

  /**
   * View name
   */
  this.view = "";

  /**
   * The fields of the table
   */
  this.fields = new Array();

  /**
   * Left quote for table or column name
   */
  this.lq = "[";

  /**
   * Right quote for table or column name
   */
  this.rq = "]";

  /**
   * Get the fields of the table
   * @return void
   */
  this.getFields = function() {
    if (this.fields.length > 0 || this.table == "") {
      return;
    }
    var path = APPPATH + "data\\fields\\";
    if (this.db != "") {
      path += this.db + "_";
    }
    path += this.table + ".asp";
    if ($.File.isFile(path)) {
      eval(include(path));
    } else {
      var sql = "";
      var rs, field;
      switch (this.type) {
        case "access":
          var conn = (this.db != "" && defined($.DB.config[this.db])) ? $.DB.config[this.db]["conn"] : $.DB.conn;
          rs = conn.OpenSchema(adSchemaColumns);
          var start = false;
          while (!rs.EOF) {
            if (rs("TABLE_NAME").Value.toLowerCase() == this.table.toLowerCase()) {
              start = true;
            } else if (start == true){
              break;
            }
            field = ucfirst(rs("COLUMN_NAME").Value);
            var type = AccessDataType(rs("DATA_TYPE").Value);
            var size = "";
            if (rs("NUMERIC_PRECISION").Value != null) {
              size = rs("NUMERIC_PRECISION").Value
            } else if(rs("DATETIME_PRECISION").Value != null) {
              size = rs("DATETIME_PRECISION").Value;
            } else if(rs("CHARACTER_MAXIMUM_LENGTH").Value != null) {
              size = rs("CHARACTER_MAXIMUM_LENGTH").Value;
              if (size > 255) {
                type = "memo"
                size = "";
              }
            }
            this.fields[field] = {
              "name": rs("COLUMN_NAME").Value,
              "type": type,
              "size": size,
              "null": rs("IS_NULLABLE").Value,
              "default": (rs("COLUMN_DEFAULT").Value != null) ? rs("COLUMN_DEFAULT").Value : "",
              "auto": (rs("DATA_TYPE").Value == 3 && rs("COLUMN_FLAGS").Value == 24) ? true : false
            };
            rs.MoveNext();
          }
          rs.Close();
          break;
        case "mssql":
          sql = "EXEC sp_columns '" + this.table + "'";
          rs = this.query(sql);
          while (!rs.EOF) {
            field = ucfirst(rs("COLUMN_NAME").Value);
            var a = rs("TYPE_NAME").Value.split(" ");
            var type = a[0];
            var auto = (a.length > 1) ? true : false;
            this.fields[field] = {
              "name": rs("COLUMN_NAME").Value,
              "type": type,
              "size": rs("LENGTH"),
              "null": (rs("NULLABLE").Value == 0) ? true : false,
              "default": rs("COLUMN_DEF").Value,
              "auto": auto
            };
            rs.MoveNext();
          }
          rs.Close();
          if (this.pkey == "") {
            rs = this.query("EXEC sp_pkeys '" + this.table + "'");
            if (!rs.EOF) {
              this.pkey = rs("COLUMN_NAME").Value;
            }
            rs.Close();
          }
          break;
        case "mysql":
          sql = "DESCRIBE " + this.addQuote(this.table);
          rs = this.query(sql);
          while (!rs.EOF) {
            field = ucfirst(rs("Field").Value);
            if (this.pkey == "" && rs("Key").Value == "PRI") {
              this.pkey = rs("Key").Value;
            }
            var a = rs("Type").Value.split("(");
            var type = a[0];
            var size = (a.length > 1) ? a[1].replace(/\)$/, "") : "";
            this.fields[field] = {
              "name": rs("Field").Value,
              "type": type,
              "size": size,
              "null": (rs("Null").Value == "NO") ? false : true,
              "default": rs("Default").Value.replace(/^\(|\)$/, ""),
              "auto": (rs("Extra").Value != "") ? true : false
            };
            rs.MoveNext();
          }
          rs.Close();
          break;
        case "oracle":
          sql = "SELECT * FROM col WHERE TNAME='" + this.table + "'";
          rs = this.query(sql);
          while (!rs.EOF) {
            field = ucfirst(rs("CNAME").Value);
            this.fields[field] = {
              "name": rs("CNAME").Value,
              "type": rs("COLTYPE").Value,
              "size": rs("WIDTH").Value,
              "null": (rs("NULLS").Value == "NULL") ? true : false,
              "default": rs("DEFAULTVAL").Value,
              "auto": ""
            };
            rs.MoveNext();
          }
          rs.Close();
          break;
        case "pgsql":
          sql = "SELECT pg_attribute.attname,pg_type.typname,pg_attribute.attlen,pg_attribute.attnotnull FROM pg_type INNER JOIN pg_attribute ON (pg_type.oid=pg_attribute.atttypid) INNER JOIN pg_class ON (pg_class.relfilenode=pg_attribute.attrelid) WHERE pg_attribute.attstattarget<>0 AND pg_class.relname='" + this.table + "'";
          rs = this.query(sql);
          while (!rs.EOF) {
            field = ucfirst(rs("attname").Value);
            var size = (rs("attlen").Value > -1) ? rs("attlen").Value : "";
            this.fields[field] = {
              "name": rs("attname").Value,
              "type": rs("typname").Value,
              "size": size,
              "null": (rs("attnotnull").Value == "t") ? true : false,
              "default": "",
              "auto": ""
            };
            rs.MoveNext();
          }
          rs.Close();
          break;
        case "sqlite":
          sql = "PRAGMA table_info(" + this.addQuote(this.table) + ")";
          rs = this.query(sql);
          while (!rs.EOF) {
            field = ucfirst(rs("name").Value);
            if (this.pkey == "" && rs("pk").Value == 1) {
              this.pkey = rs("name").Value;
            }
            var a = rs("type").Value.split("(");
            var type = a[0];
            var size = (a.length > 1) ? a[1].replace(/\)$/, "") : "";
            this.fields[field] = {
              "name": rs("name").Value,
              "type": type,
              "size": size,
              "null": (rs("notnull").Value == 0) ? true : false,
              "default": rs("dflt_value").Value,
              "auto": (rs("pk").Value == 1 && type == "INTEGER") ? true : false
            };
            rs.MoveNext();
          }
          rs.Close();
          break;
      }
      // Write fields to the file
      $.File.writeFile(path, serialize(this.fields, "this.fields", false));
    }
  };

  /**
   * Build query statement with arguments
   * @param  fields     [optional]the fields to fetch
   * @param  conditions [optional]the conditions to search
   * @param  orders     [optional]order by columns
   * @param  limit      [optional]the number of rows to fetch
   * @param  offset     [optional]the offset in rows to seek
   * @return string
   */
  this.buildQuery = function(fields, conditions, orders, limit, offset) {
    var top = "";
    var end = "";
    var sql = "";
    var obj = (this.table != "") ? this.table : this.view;
    if (!defined(fields) || fields == "") {
      fields = "*";
    }
    if (!defined(conditions)) {
      conditions = "";
    }
    if (!defined(orders)) {
      orders = "";
    }
    if (!defined(limit)) {
      limit = 100;
    }
    if (!defined(offset)) {
      offset = 0;
    }
    switch (this.type) {
      case "access":
      case "mssql": top = "TOP " + limit + " ";break;
      case "mysql":
      case "postgresql":
      case "sqlite": end = " LIMIT " + limit + " OFFSET " + offset;break;
    }
    if (top != "" && this.pkey != "" && offset > 0) {
      sql = "SELECT " + top + this.addQuote(fields) + " FROM " + this.addQuote(obj) + " WHERE ";
      if (conditions != "") {
        sql += "(" + this.addQuote(conditions) + ") AND "
      }
      sql += this.addQuote(this.pkey) + " NOT IN (SELECT TOP " + offset + " " + this.addQuote(this.pkey) + " FROM " + this.addQuote(this.table);
      if (conditions != "") {
        sql += " WHERE " + this.addQuote(conditions);
      }
      if (order != "") {
        sql += " ORDER BY " + this.addQuote(orders) + ") ORDER BY " + orders;
      } else {
        sql += ")";
      }
    } else {
      sql = "SELECT " + top + this.addQuote(fields) + " FROM " + this.addQuote(obj);
      if (conditions != "") {
        sql += " WHERE " + this.addQuote(conditions);
      }
      if (orders != "") {
        sql += " ORDER BY " + this.addQuote(orders);
      }
      sql += end;
    }

    return sql;
  };

  /**
   * Add table or column quote for query
   * @param  str  the string to add quote
   * @return string
   */
  this.addQuote = function(str) {
    var lq = this.lq;
    var rq = this.rq;
    if (/[a-z0-9_]+\s*(<|>|=|<=|>=|<>|EXISTS|IN|LIKE|NOT)/i.test(str)) {
      return str.replace(/([a-z0-9_]+)\s*(<|>|=|<=|>=|<>|EXISTS|IN|LIKE|NOT)/ig, function() {
        return lq + $1.replace(/\./g, rq + "." + lq) + rq;
      });
    } else {
      var a = str.split(",");
      for (var i = 0; i < a.length; i++) {
        a[i] = a[i].replace(/([a-z0-9_]+)/i, function($1) {
          return lq + $1.replace(/\./g, rq + "." + lq) + rq;
        });
      }
      return a.join(",");
    }
  };

  /**
   * Create the table
   * @return boolean
   */
  this.create = function() {
    if (this.table == "") {
      return false;
    }
    var sql = "CREATE TABLE " + this.addQuote(this.table) + " (";
    var first = true;
    for (var field in this.fields) {
      if (!first) {
        sql += ",";
        first = false;
      }
      sql += this.addQuote(this.fields[field]["name"]);
      if (!(this.type == "access" && this.fields[field]["auto"] == true)) {
        sql += " " + this.fields[field]["type"];
        if (this.fields[field]["size"] != "") {
          sql += "(" + this.fields[field]["size"] + ")";
        }
        if (this.fields[field]["null"] != "") {
          if (this.fields[field]["null"] == false) {
            sql += " NOT NULL";
          } else if(isString(this.fields[field]["null"])) {
            sql += " " + this.fields["field"]["null"];
          }
        }
        if (this.fields[field]["default"] != "") {
          sql += " " + this.fields[field]["default"];
        }
      }
      if (this.fields[field]["auto"] != "") {
        if (this.fields[field]["auto"] == true) {
          switch (this.type) {
            case "access":
              sql += " COUNTER(1, 1)";
              break;
            case "mssql":
              sql += " IDENTITY(1, 1)";
              break;
            case "mysql":
              sql += " AUTO_INCREMENT";
              break;
            case "oracle":
              break;
            case "sqlite":
              sql += " AUTOINCREMENT";
              break;
          }
        } else if(isString(this.fields[field]["auto"])) {
          sql += " " + this.fields[field]["auto"];
        }
      }
    }
    if (this.pkey != "") {
      sql += ",";
      sql += "PRIMARY KEY (" + this.addQuote(this.pkey) + ")";
    }
    sql += ")";
    return this.execute(sql);
  };

  /**
   * Fetch a row
   * @param  fields     [optional]the fields to fetch
   * @param  conditions [optional]the conditions to search
   * @param  orders     [optional]order by columns
   * @return object
   */
  this.fetch = function(fields, conditions, orders) {
    var sql = this.buildQuery(fields, conditions, orders, 1);
    var rs = this.query(sql);
    var obj = null;
    if (!rs.EOF) {
      obj = new Object();
      var len = rs.Fields.Count;
      for (var i = 0; i < len; i ++) {
        var tmp = rs.Fields.Item(i).Value;
        if (isDate(tmp)) {
          obj[rs.Fields.Item(i).Name] = new Date(tmp);
        } else {
          obj[rs.Fields.Item(i).Name] = tmp;
        }
      }
    }
    rs.Close();

    return obj;
  };

  /**
   * Fetch all rows with limit
   * @param  fields     [optional]fields to fetch
   * @param  conditions [optional]the conditions to search
   * @param  orders     [optional]order by columns
   * @param  limit      [optional]the number of rows to fetch
   * @param  offset     [optional]the offset in rows to seek
   * @return array
   */
  this.fetchAll = function(fields, conditions, orders, limit, offset) {
    var sql = this.buildQuery(fields, conditions, orders, limit, offset);
    var rs = this.query(sql);
    var a = new Array();
    var len = 0;
    //return rs;
    while (!rs.EOF) {
      var obj = new Object();
      if (len == 0) {
        len = rs.Fields.Count;
      }
      for (var i = 0; i < len; i ++) {
        var tmp = rs.Fields.Item(i).Value;
        if (isDate(tmp)) {
          obj[rs.Fields.Item(i).Name] = new Date(tmp);
        } else {
          obj[rs.Fields.Item(i).Name] = tmp;
        }
      }
      a.push(obj);
      rs.MoveNext();
    }
    rs.Close();

    return a;
  };

  /**
   * Save the model with data
   * @param  model  the model object to save
   * @return boolean
   */
  this.save = function(model) {
    if (this.table == "") {
      return false;
    }
    if (!isObject(model)) {
      error("The model must be an object");
    }
    var sql = "";
    var pkey = "";
    if (defined(this.fields[ucfirst(this.pkey)])) {
      pkey = ucfirst(this.pkey);
    }
    if (pkey != "" && model[pkey] != "") {
      sql = "UPDATE " + this.addQuote(this.table) + " SET ";
      var first = true;
      for (var field in this.fields) {
        if (field != this.pkey && model[field] != null) {
          if (!first) {
            sql += ","
            first = false;
          }
          sql += this.addQuote(this.fields[field]["name"]) + "=" + model[field];
        }
      }
      sql += " WHERE " + this.addQuote(this.pkey) + "=" + model[pkey];
    } else {
      sql = "INSERT INTO " + this.addQuote(this.table) + "(";
      var sFields = "";
      var sValues = "";
      var first = true;
      for (var field in this.fields) {
        if (model[field] != null) {
          if (!first) {
            sFields += ",";
            sValues += ",";
            first = false;
          }
          sFields += this.addQuote(this.fields[field]["name"]);
          sValues += model[field];
        }
      }
      var sql = "INSERT INTO " + this.addQuote(this.table) + "(" + sFields + ") VALUES(" + sValues + ")";
    }

    return this.execute(sql);
  };

  /**
   * Remove rows with the condition
   * @param  conditions  the condition to search
   * @return boolean
   */
  this.remove = function(conditions) {
    if (this.table == "" || !defined(conditions)) {
      return false;
    }
    var sql = "DELETE FROM " + this.addQuote(this.table) + " WHERE " + this.addQuote(conditions);

    return this.execute(sql);
  };

  /**
   * Execute SQL statement or procedure and return no result
   * @param  cmdText  the command text or procedure name
   * @param  cmdType  [optional]the command type, default is adCmdText
   * @param  params   [optional]the parameters to bind
   * @return boolean
   */
  this.execute = function(cmdText, cmdType, params) {
    var ret = $.DB.execute(this.db, cmdText, cmdType, params);
    if (ret && this.table != "") {
      var file = (this.db != "") ? this.db + "_" + this.table : this.table;
      file = file.toLowerCase();
      $.File.touch(APPPATH + "data\\modified\\" + file);
    }

    return ret;
  };

  /**
   * Execute SQL statement or procedure and return data as recordset
   * @param  cmdText  the command text or procedure name
   * @param  cmdType  [optional]the command type, default is adCmdText
   * @param  params   [optional]the parameters to bind
   * @return recordset
   */
  this.query = function(cmdText, cmdType, params) {
    return $.DB.query(this.db, cmdText, cmdType, params);
  };

  /**
   * Get the id of the last inserted row
   * @return Integer
   */
  this.inserted = function() {
    if (this.table == "") {
      return false;
    }
    var rs = this.query("SELECT MAX(" + this.addQuote(this.pkey) + ") AS rowid FROM " + this.addQuote(this.table));
    var id = (!rs.EOF) ? rs("rowid").Value : false;
    rs.Close();

    return id;
  }

  // Initialize the model
  if (defined(base)) {
    extend(this, base);
  }
  if (this.table == "" && this.view == "") {
    error("Table or view undefined");
  }
  this.type = (this.db != "" && defined($.DB.config[this.db])) ? $.DB.config[this.db]["type"] : $.DB.type;
  if (this.type == "mysql") {
    this.lq = this.rq = "`";
  } else if(this.type == "oracle" || this.type == "pgsql") {
    this.lq = this.rq = '"';
  }
  var model_file = (this.db != "") ? this.db + "_" + this.table : this.table;
  model_file = model_file.toLowerCase();
  if (!find(TABLES, model_file)) {
    TABLES.push(model_file);
  }
}

function AccessDataType(id) {
  switch (id) {
    case 2: return "smallint";
    case 3: return "integer";
    case 4: return "single";
    case 5: return "double";
    case 6: return "currency";
    case 11: return "bit";
    case 130: return "varchar";
    case 135: return "datetime";
    default: return "varchar";
  }
}
%>