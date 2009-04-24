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
 * @package   DB
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

// Load database configuration
if ($.File.isFile(APPPATH + "config\\database.asp")) {
  eval(include(APPPATH + "config\\database.asp"));
}

/**
 * Class DB
 */
function DB() {
  if (defined(CONFIG["db"])) {
    var default_name = "";
    for (name in CONFIG["db"]) {
      if (default_name == "") {
        default_name = name;
      }
      this.open(CONFIG["db"][name], name);
    }
    if (default_name != "") {
      this.use(default_name);
    }
  }
}

DB.prototype = {

  /**
   * Database configuration
   */
  config: new Array(),

  /**
   * Data source string
   */
  dsn: "",

  /**
   * Current database configuration name
   */
  name: "",

  /**
   * Current database type
   */
  type: "",

  /**
   * Current database connection
   */
  conn: null,

  /**
   * Set data source parameters
   * @param  options  the data source strings
   * @return void
   */
  setDsn: function(options) {
    if (!defined(options["driver"])) {
      return;
    }
    var dsn = "DRIVER=" + options["driver"] + ";";
    if (defined(options["user"])) {
      dsn += "UID=" + options["user"] + ";";
    }
    if (defined(options["password"])) {
      dsn += "PASSWORD=" + options["password"] + ";";
    }
    if (defined(options["server"])) {
      dsn += "SERVER=" + options["server"] + ";";
    }
    if (defined(options["port"])) {
      dsn += "PORT=" + options["port"] + ";";
    }
    if (defined(options["database"])) {
      if (/Access/i.test(options["driver"])) {
        dsn += "DBQ=" + realpath(options["database"]) + ";";
      } else {
        dsn += "DATABASE=" + options["database"] + ";";
      }
    }
    this.dsn = dsn;
  },

  /**
   * Use the connection with the configuration name
   * @param  name  the database configuration name
   * @return void
   */
  use: function(name) {
    if (defined(this.config[name])) {
      this.name = name;
      this.type = this.config[name]["type"];
      this.conn = this.config[name]["conn"];
    }
  },

  /**
   * Open a database connection
   * @param  dsn  [optional]the data souce string
   * @param  name [optional]the connection name
   * @return boolean
   */
  open: function(dsn, name) {
    if (defined(dsn)) {
      if (isString(dsn)) {
        this.dsn = dsn;
      } else {
        this.setDsn(dsn);
      }
    }
    if (this.dsn != "") {
      var dbtype = "";
      var m = this.dsn.match(/driver=\{([^\}]+)\}/i);
      if (m) {
        if (/access/i.test(m[1])) {
          dbtype = "access";
        } else if (/sql server/i.test(m[1])) {
          dbtype = "mssql";
        } else if (/mysql/i.test(m[1])) {
          dbtype = "mysql";
        } else if (/oracle/i.test(m[1])) {
          dbtype = "oracle";
        } else if (/postgresql/i.test(m[1])) {
          dbtype = "pgsql";
        } else if (/sqlite/i.test(m[1])) {
          dbtype = "sqlite";
        }
      }
      if (dbtype == "") {
        die("The type of the database not supported");
      }
      try {
        if (defined(name)) {
          this.config[name] = new Array();
          this.config[name]["type"] = dbtype;
          this.config[name]["conn"] = Server.CreateObject("ADODB.Connection");
          this.config[name]["conn"].Open(this.dsn);
        } else {
          this.type = dbtype;
          this.conn = Server.CreateObject("ADODB.Connection");
          this.conn.Open(this.dsn);
        }
        this.dsn = "";
        return true;
      } catch (e) {
        if (defined(name)) {
          die("Open " + name + " database failed");
        } else {
          die("Open the database failed");
        }
      }
    }
  },

  /**
   * Close the current database connection
   * @return void
   */
  close: function() {
    this.conn.Close();
    this.conn = null;
    if (this.name != "") {
      delete this.config[this.name];
    }
  },

  /**
   * Close all the database connections in the list
   * @return void
   */
  closeAll: function() {
    for (name in this.config) {
      this.config[name]["conn"].Close();
    }
    this.config = null;
    this.conn = null;
  },

  /**
   * Execute SQL statement or procedure and return no result
   * @param  name     the database configuration name to use
   * @param  cmdText  the command text or procedure name
   * @param  cmdType  [optional]the command type, default is adCmdText
   * @param  params   [optional]the parameters to bind
   * @return boolean
   */
  execute: function(name, cmdText, cmdType, params) {
    var affected = 0;
    if (!defined(cmdType)) {
      cmdType = adCmdText;
    }
    try {
      var conn = (name != "" && defined(this.config[name])) ? this.config[name]["conn"] : this.conn;
      if (!defined(params) || !isArray(params)) {
        conn.Execute(cmdText, affected, cmdType);
      } else {
        var cmd = Server.CreateObject("ADODB.Command");
        cmd.ActiveConnection = conn;
        cmd.NamedParameters = true;
        cmd.CommandText = cmdText;
        cmd.CommandType = cmdType;
        if (isArray(params[0])) {
          for (param in params) {
            cmd.Parameters.Append(cmd.CreateParameter(param[0], param[1], param[2], param[3], param[4]));
          }
        } else {
          cmd.Parameters.Append(cmd.CreateParameter(params[0], params[1], params[2], params[3], params[4]));
        }
        cmd.Execute(affected);
      }
    } catch (e) {
      die("Error occured while executing the statement");
    }

    return affected > 0 ? true : false;
  },

  /**
   * Execute SQL statement or procedure and return data as recordset
   * @param  name     the database configuration name to use
   * @param  cmdText  the command text or procedure name
   * @param  cmdType  [optional]the command type, default is adCmdText
   * @param  params   [optional]the parameters to bind
   * @return recordset
   */
  query: function(name, cmdText, cmdType, params) {
    if (!defined(cmdType)) {
      cmdType = adCmdText;
    }
    try {
      var conn = (name != "" && defined(this.config[name])) ? this.config[name]["conn"] : this.conn;
      var cmd = Server.CreateObject("ADODB.Command");
      cmd.ActiveConnection = conn;
      cmd.NamedParameters = true;
      cmd.CommandText = cmdText;
      cmd.CommandType = cmdType;
      if (defined(params)) {
        if (isArray(params[0])) {
          for (param in params) {
            cmd.Parameters.Append(cmd.CreateParameter(param[0], param[1], param[2], param[3], param[4]));
          }
        } else {
          cmd.Parameters.Append(cmd.CreateParameter(params[0], params[1], params[2], params[3], params[4]));
        }
      }
      var rs = cmd.Execute();
    } catch (e) {
      die("Error occured while executing the statement");
    }

    return rs;
  },

  /**
   * Make input parameters
   * @param  name  the name of the parameter
   * @param  type  the type of the parameter
   * @param  size  the size of the parameter
   * @param  value the value of the parameter
   * @return array
   */
  makeInParam: function(name, type, size, value) {
    return [name, type, adParamInput, size, value];
  },

  /**
   * Make output parameters
   * @param  name  the name of the parameter
   * @param  type  the type of the parameter
   * @param  size  the size of the parameter
   * @param  value the value of the parameter
   * @return array
   */
  makeOutParam: function(name, type, size, value) {
    return [name, type, adParamOutput, size, value];
  }

}

$.DB = new DB();
%>