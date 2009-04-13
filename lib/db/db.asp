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
    var default = "";
    for (name in CONFIG["db"]) {
      if (default == "") {
        default = name;
      }
      this.open(CONFIG["db"][name], name);
    }
    if (default != "") {
      this.use(default);
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
      if (find(/Access/i, options["driver"])) {
        dsn += "DBQ=" + realpath(options["database"]) + ";";
      } else {
        dsn += "DATABASE=" + options["database"] + ";";
      }
    }
    this.dsn = dsn;
  },

  /**
   * Use the connection with the config name
   * @param  name  the database config name
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
        if (m[1].match(/access/i)) {
          dbtype = "access";
        } else if (m[1].match(/sql server/i)) {
          dbtype = "mssql";
        } else if (m[1].match(/mysql/i)) {
          dbtype = "mysql";
        } else if (m[1].match(/oracle/i)) {
          dbtype = "oracle";
        } else if (m[1].match(/postgresql/i)) {
          dbtype = "pgsql";
        } else if (m[1].match(/sqlite/i)) {
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
        } else {
          this.type = dbtype;
          this.conn = Server.CreateObject("ADODB.Connection");
          this.conn.Open(this.dsn);
        }
        this.dsn = "";
        return true;
      } catch (e) {
        if (!defined(name)) {
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
   * @param  cmdText  the command text or procedure name
   * @param  cmdType  [optional]the command type, default is adCmdText
   * @param  params   [optional]the parameters to bind
   * @return boolean
   */
  execute: function(cmdText, cmdType, params) {
    var affected = 0;
    if (!defined(cmdType)) {
      cmdType = adCmdText;
    }
    try {
      if (!defined(params) || !isArray(params)) {
        this.conn[this.id].Execute(cmdText, affected, cmdType);
      } else {
        var cmd = Server.CreateObject("ADODB.Command");
        cmd.ActiveConnection = this.conn[this.id];
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
   * @param  cmdText  the command text or procedure name
   * @param  cmdType  [optional]the command type, default is adCmdText
   * @param  params   [optional]the parameters to bind
   * @return recordset
   */
  query: function(cmdText, cmdType, params) {
    if (!defined(cmdType)) {
      cmdType = adCmdText;
    }
    try {
      var rs = Server.CreateObject("ADODB.Recordset");
      var cmd = Server.CreateObject("ADODB.Command");
      cmd.ActiveConnection = this.conn[this.id];
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
      rs = cmd.Execute();
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