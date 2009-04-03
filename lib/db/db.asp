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
  this.config = new Array();
  this.id = 0;
  this.dsn = "";
  this.type = "";
  this.conn = new Array();
  if (defined(CONFIG["db"])) {
    var i = 0;
    for (name in CONFIG["db"]) {
      this.config[name] = i;
      if (!this.open(CONFIG["db"][name])) {
        die("Open " + name + " database failed");
      }
      i++;
    }
  }
}

DB.prototype = {

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
   * Set a default connection with the config name
   * @param  name  the database config name
   * @return void
   */
  setDefault: function(name) {
    if (defined(this.config[name])) {
      this.id = this.config[name];
    }
  },

  /**
   * Open a database connection
   * @param  dsn  [optional]the data souce string
   * @return boolean
   */
  open: function(dsn) {
    if (defined(dsn)) {
      if (isString(dsn)) {
        this.dsn = dsn;
      } else {
        this.setDsn(dsn);
      }
    }
    if (this.dsn != "") {
      var m = this.dsn.match(/driver=\{([^\}]+)\}/i);
      if (m) {
        if (m[1].match(/access/i)) {
          this.type = "access";
        } else if (m[1].match(/sql server/i)) {
          this.type = "mssql";
        } else if (m[1].match(/mysql/i)) {
          this.type = "mysql";
        } else if (m[1].match(/oracle/i)) {
          this.type = "oracle";
        } else if (m[1].match(/postgresql/i)) {
          this.type = "pgsql";
        } else if (m[1].match(/sqlite/i)) {
          this.type = "sqlite";
        }
      }
      if (this.type == "") {
        die("The type of the database not supported");
      }
      try {
        var i = this.conn.length;
        this.conn[i] = Server.CreateObject("ADODB.Connection");
        this.conn.length = i + 1;
        this.conn[i].Open(this.dsn);
        this.dsn = "";
        return true;
      } catch (e) {
        return false;
      }
    }
  },

  /**
   * Switch the database connection with the index of the connection list
   * @param  i  the index of the connection list
   * @return void
   */
  switchConnection: function(i) {
    if (id >= 0 && id < this.conn.length) {
      this.id = id;
    }
  },

  /**
   * Close the current database connection
   * @return void
   */
  close: function() {
    var i = this.id;
    this.conn[i].Close();
    this.conn[i] = null;
  },

  /**
   * Close all the database connections in the list
   * @return void
   */
  closeAll: function() {
    var n = this.conn.length;
    for (i = 0; i < n; i++) {
      this.conn[i].Close();
    }
    this.conn = new Array();
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