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

$.Model = {

  db: "",

  table: "",

  pkey: "",

  fields: "",

  belongsTo: "",

  hasMany: "",

  manyToMany: "",

  init: function() {
    if (this.db != "") {
      $.DB.setDefault(this.db);
    }
  },

  getFields: function() {
  },

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
      "access":
      "mssql": top = "TOP " + limit + " ";break;
      "mysql":
      "postgresql":
      "sqlite": end = " LIMIT " + limit + " OFFSET " + offset;break;
    }
    if (top != "" && this.pkey != "" && offset > 0) {
      sql = "SELECT " + top + fields + " FROM " + this.table + " WHERE ";
      if (conditions != "") {
        sql += "(" + conditions + ") AND "
      }
      sql += this.pkey + " NOT IN (SELECT TOP " + offset + " " + this.pkey + " FROM " + this.table;
      if (conditions != "") {
        sql += " WHERE " + conditions;
      }
      if (order != "") {
        sql += " ORDER BY " + orders + ") ORDER BY " + orders;
      }
    } else {
      sql = "SELECT " + top + fields + " FROM " + this.table;
      if (conditions != "") {
        sql += " WHERE " + conditions;
      }
      if (orders != "") {
        sql += " ORDER BY " + orders;
      }
      sql += end;
    }
    return sql;
  },

  /**
   * Fetch a row
   * @param  fields     fields to fetch
   * @param  conditions the where condition
   * @param  orders     order the result
   * @return object
   */
  fetch: function(fields, conditions, orders) {
    var sql = this.buildQuery(fields, conditions, orders, 1);
    var rs = $.DB.query(sql);
  },

  /**
   * Fetch all rows with limit
   * @param  fields     fields to fetch
   * @param  conditions the where condition
   * @param  orders     order the result
   * @param  limit      number of rows to fetch
   * @param  offset     offset of rows to seek
   * @return object
   */
  fetchAll: function(fields, conditions, orders, limit, offset) {
    var sql = this.buildQuery(fields, conditions, orders, limit, offset);
    var rs = $.DB.query(sql);
  },

  save: function() {
  },

  remove: function(conditions) {
    if (!defined(conditions)) {
      return false;
    }
    return $.DB.execute("DELETE FROM " + this.table + " WHERE " + conditions);
  }

}
%>