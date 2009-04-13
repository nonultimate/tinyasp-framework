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

$.Model = function() {
  if (!defined(this.constructor)) {
    die("Model class must be extended");
  }
  var c = this.constructor.toString();
  var a = c.match(/function\s+([^\s\(]+)/i);
  c = a[1].replace(/Model$/, "");
  if (this.table == "") {
    this.table = c;
  }
  if (this.db != "") {
    $.DB.use(this.db);
  }
  if (this.type == "mysql") {
    this.lq = this.rq = "`";
  } else if(this.type == "oracle") {
    this.lq = this.rq = '"';
  }
}

$.Model.prototype = {

  /**
   * Database configuration name
   */
  db: "",

  /**
   * Table name
   */
  table: "",

  /**
   * Primary key
   */
  pkey: "",

  /**
   * The fields of the table
   */
  fields: new Array(),

  /**
   * Left quote for table or column name
   */
  lq: "[",

  /**
   * Right quote for table or column name
   */
  rq: "]",

  hasOne: "",

  belongsTo: "",

  hasMany: "",

  manyToMany: "",

  /**
   * Get the fields of the table
   * @return void
   */
  getFields: function() {
  },

  /**
   * Build query statement with arguments
   * @param  fields     [optional]the fields to fetch
   * @param  conditions [optional]the conditions to search
   * @param  orders     [optional]order by columns
   * @param  limit      [optional]the number of rows to fetch
   * @param  offset     [optional]the offset in rows to seek
   * @return string
   */
  buildQuery: function(fields, conditions, orders, limit, offset) {
    var top = "";
    var end = "";
    var sql = "";
    if (!defined(fields) || fields == "") {
      fields = "*";
    }
    if (!defined(conditions)) {
      condition = "";
    }
    if (!defined(orders)) {
      order = "";
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
      sql = "SELECT " + top + this.addQuote(fields) + " FROM " + this.addQuote(this.table) + " WHERE ";
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
      sql = "SELECT " + top + this.addQuote(fields) + " FROM " + this.addQuote(this.table);
      if (conditions != "") {
        sql += " WHERE " + this.addQuote(conditions);
      }
      if (orders != "") {
        sql += " ORDER BY " + this.addQuote(orders);
      }
      sql += end;
    }
    return sql;
  },

  /**
   * Add table or column quote for query
   * @param  str  the string to add quote
   * @return string
   */
  addQuote: function(str) {
    if (str.match(/[a-z0-9_]+\s*(<|>|=|<=|>=|<>|EXISTS|IN|LIKE|NOT)/i)) {
      return str.replace(/([a-z0-9_]+)\s*(<|>|=|<=|>=|<>|EXISTS|IN|LIKE|NOT)/ig, function() {
        return this.lq + $1.replace(/\./g, this.rq + "." + this.lq) + this.rq;
      });
    } else {
      var a = str.split(",");
      for (i = 0; i < a.length; i++) {
        a[i] = a[i].replace(/([a-z0-9_]+)/i, function($1) {
          return this.lq + $1.replace(/\./g, this.rq + "." + this.lq) + this.rq;
        });
      }
      return a.join(",");
    }
  },

  /**
   * Create the table
   * @return boolean
   */
  create: function() {
    var sql = "CREATE TABLE " + this.addQuote(this.table) + " (";
    var first = true;
    for (field in this.fields) {
      if (!first) {
        sql += ",";
        first = false;
      }
      sql += this.addQuote(this.fields[field]["name"]) + " " + this.fields[field]["type"];
      if (this.fields[field]["size"] != "") {
        sql += "(" + this.fields[field]["size"] + ")";
      }
      if (this.fields[field]["null"] != "") {
        sql += " " + this.fields[field]["null"];
      }
      if (this.fields[field]["default"] != "") {
        sql += " " + this.fields[field]["default"];
      }
      if (this.fields[field]["auto"] != "") {
        sql += " " + this.fields[field]["auto"];
      }
    }
    if (this.pkey != "") {
      sql += ",";
      sql += "PRIMARY KEY (" + this.addQuote(this.pkey) + ")";
    }
    sql += ")";
    return $.DB.execute(sql);
  },

  /**
   * Fetch a row
   * @param  fields     [optional]the fields to fetch
   * @param  conditions [optional]the conditions to search
   * @param  orders     [optional]order by columns
   * @return object
   */
  fetch: function(fields, conditions, orders) {
    var sql = this.buildQuery(fields, conditions, orders, 1);
    var rs = $.DB.query(sql);
  },

  /**
   * Fetch all rows with limit
   * @param  fields     [optional]fields to fetch
   * @param  conditions [optional]the conditions to search
   * @param  orders     [optional]order by columns
   * @param  limit      [optional]the number of rows to fetch
   * @param  offset     [optional]the offset in rows to seek
   * @return object
   */
  fetchAll: function(fields, conditions, orders, limit, offset) {
    var sql = this.buildQuery(fields, conditions, orders, limit, offset);
    var rs = $.DB.query(sql);
  },

  /**
   * Save the model with data
   * @param  model  [optional]the model object to save
   * @return boolean
   */
  save: function(model) {
    if (!defined()) {
      model = this;
    }
    if (!isObject(model)) {
      die("The model must be an object");
    }
    var sql = "";
    var pkey = "";
    for (field in this.fields) {
      if (this.fields[field]["name"] == this.pkey) {
        pkey = field;
        break;
      }
    }
    if (pkey != "" && model[pkey] != "") {
      sql = "UPDATE " + this.addQuote(this.table) + " SET ";
      var first = true;
      for (field in this.fields) {
        if (field != this.pkey) {
          if (model[field] != null) {
            if (!first) {
              sql += ","
              first = false;
            }
            sql += this.addQuote(this.fields[field]["name"]) + "=" + model[field];
          }
        }
      }
      sql += " WHERE " + this.addQuote(this.pkey) + "=" + model[pkey];
    } else {
      sql = "INSERT INTO " + this.addQuote(this.table) + "(";
      var sFields = "";
      var sValues = "";
      var first = true;
      for (field in this.fields) {
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
    var ret = $.DB.execute(sql);
    return ret;
  },

  /**
   * Remove rows with the condition
   * @param  conditions  the condition to search
   * @return boolean
   */
  remove: function(conditions) {
    if (!defined(conditions)) {
      return false;
    }
    var sql = "DELETE FROM " + this.addQuote(this.table) + " WHERE " + this.addQuote(conditions);
    return $.DB.execute(sql);
  }

}
%>