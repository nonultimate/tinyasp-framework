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
 * @package   Include
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

var StartTime = timer();
var APPROOT = TServer("APPL_PHYSICAL_PATH");
var APPLIB = APPROOT + "lib\\";
var APPPATH = APPROOT + "app\\";
var INCLUDE_ONCE = new Array();
var CONFIG = new Array();

// Initialize variables
INCLUDE_ONCE[APPLIB + "include\\functions.asp"] = 1;

// Set up default configuration
CONFIG["buffer"] = true;
CONFIG["charset"] = "UTF-8";
CONFIG["template_extension"] = "html";
CONFIG["cache_view"] = true;

/**
 * Return program executing time
 * @return string
 */
function runtime() {
  time = new String(Math.round((timer() - StartTime)) / 1000);
  if (time.substr == ".") {
    time = "0" + time;
  }

  return time;
}

/**
 * Get milliseconds of current time
 * @return integer
 */
function timer() {
  return (new Date()).getTime();
}

/**
 * Output string
 * @param  str  the string to output
 * @return void
 */
function echo(str) {
  Response.Write(str);
}

/**
 * Output string
 * @param  str  the string to output
 * @return void
 */
function print(str) {
  echo(str);
}

/**
 * Output string and change line
 * @param  str  the string to output
 * @return void
 */
function println(str) {
  echo(str + "\n");
}

/**
 * Output string and exit
 * @param  str  the string to output
 * @return void
 */
function die(str) {
	Response.Write(str);
	Response.End;
}

/**
 * Throw an error and exit
 * @param  str  the error message
 * @param  err  [optional]the error object
 * @return void
 */
function error(str, err) {
  setContentType("text/plain");
  if (defined(err)) {
    die(msg + "\n" + err.description);
  } else {
    die(msg);
  }
}

/**
 * Output a object or variable
 * @param  v  the object or variable to output
 * @return void
 */
function dump(v) {
  if (isObject(v) || isFunction(v)) {
    println(typeof v + " (");
    var first = true;
    for (key in v) {
      if (first) {
        first = false;
      } else {
        println(",");
      }
      print(key + " => ");
      if (isObject(v[key]) || isFunction(v[key])) {
        dump(v[key]);
      } else {
        print(v[key]);
      }
    }
    println(")");
  } else {
    println(v);
  }
}

/**
 * Redirect URL
 * If url is a number, it will redirect to error page with HTTP state code (0, 403, 404). 
 * @param  url  the URL of the location to redirect, or HTTP state code
 * @return void
 */
function redirect(url) {
  if (isNumber(url)) {
    var page = "/errors/error.html";
    switch(url) {
      case 403: page = "/errors/403.html";
      case 404: page = "/errors/404.html";
    }
    transfer(page);
  } else {
    Response.Redirect(url);
    Response.End;
  }
}

/**
 * Transfer URL without parameters
 * @param  url  the URL of the location to transfer
 * @return void
 */
function transfer(url) {
  Server.Transfer(url);
}

/**
 * Set HTTP content type
 * @param  type  the content type
 * @return void
 */
function setContentType(type) {
  Response.ContentType = type;
}

/**
 * Set the time the page expires
 * @param  time  the time of minutes
 * @return void
 */
function setExpires(time) {
  Response.Expires = time;
}

/**
 * Set HTTP header
 * @param  name   the name of HTTP header
 * @param  value  the value of HTTP header
 * @return void
 */
function setHeader(name, value) {
  Response.AddHeader(name, value);
}

/**
 * Get the parent directory path
 * @param  path  the path of the file or folder
 * @return string
 */
function dirname(path) {
  var name = "";
  if (!isString(path)) {
    var arr = path.split(/[\\\/]/);
    if (arr.length >= 1) {
      var n = arr[arr.length - 1].length;
      name = path.substr(0, path.length - n -1);
    }
  }

  return name;
}

/**
 * Get base file name without path
 * @param  path  the path of the file or folder
 * @return string
 */
function basename(path) {
  if (!isString(path)) {
    return "";
  }
  var arr = path.split(/[\\\/]/);

  return arr[arr.length - 1];
}

/**
 * Get the absolute path
 * @param  path  the path of the file or folder
 * @return string
 */
function realpath(path) {
  if (!isString(path)) {
    return "";
  }
  if (path.match(/^[a-z]:/i)) {
    return path;
  } else {
    return Server.MapPath(path);
  }
}

/**
 * Encode HTML tag
 * @param  str  the string to encode
 * @return string
 */
function encodeHTML(str) {
  return Server.HTMLEncode(str);
}

/**
 * Encode URL string
 * @param  str  the string to encode
 * @return string
 */
function encodeURL(str) {
  return Server.URLEncode(str);
}

/**
 * Format the number as size with 'B', 'KB', 'MB', 'GB'
 * @param  size  the size of a file in bytes
 * @return string
 */
function getSize(size) {
  if (size < 1024) {
    return size + "B";
  } else if (size < 1024 * 1024) {
    return Math.round((size * 100) / 1024) / 100 + "KB";
  } else if (size < 1024 * 1024 * 1024) {
    return Math.round((size * 100 ) / (1024 * 1024)) / 100 + "MB";
  } else {
    return Math.round((size * 100 ) / (1024 * 1024 * 1024)) / 100 + "GB";
  }
}

/**
 * First letter upper case
 * @param  str  the string to format
 * @return string
 */
function ucfirst(str) {
  return str.substr(0, 1).toUpperCase() + str.substr(1);
}

/**
 * First letter of each word upper case
 * @param  str  the string to format
 * @return string
 */
function ucwords(str) {
  return str.replace(/(\S+)/g, function($0, $1) {
    return ucfirst($1);
  });
}

/**
 * Dynamic include file with repeating inclusion support,
 * like include_once function in PHP
 * @param  filename  the file path to include
 * @param  once      [optional]whether the file can be included only once, default is true.
 * @return string
 */
function include(filename, once) {
  var content, stream, tagStart, tagEnd, code;
  var path = realpath(filename);
  if (!defined(once)) {
    once = true;
  }
  if (defined(INCLUDE_ONCE[path]) && once) {
    return;
  }
  INCLUDE_ONCE[path] = 1;
  try {
    var stream = Server.CreateObject("ADODB.Stream");
    stream.Type = 2; //adTypeText
    stream.Charset = CONFIG["charset"];
    stream.Open();
    stream.LoadFromFile(path);
    content = stream.ReadText();
    stream.Close();
    code = "";
    tagEnd = 0;
    tagStart = content.indexOf("<%") + 2;
    while (tagStart - tagEnd > 1) {
      if (tagStart - tagEnd > 2) {
        code += "Response.Write(" + content.substring(tagEnd, tagStart - 2) + ");";
      }
      tagEnd = content.indexOf("%\>", tagStart) + 2;
      code += content.substring(tagStart, tagEnd - 2).replace(/^\s*=(.*)/, "Response.Write($1);");
      tagStart = content.indexOf("<%", tagEnd) + 2;
    }
    if (tagEnd < content.length) {
      code += "Response.Write(" + content.substr(tagEnd) + ");";
    }
    return code;
    //eval(code);
  } catch(e) {
    die("File \"" + path + "\" not found");
  }
}

/**
 * Import a library
 * @param  string  the library string
 * @return void
 */
function require(lib) {
  var a = lib.split(".");
  var path = (a[0] == '$') ? APPLIB : APPPATH + "lib\\";
  var len = a.length;
  for (i = 0; i < len; i++) {
    if (i > 0) {
      path += "\\";
    }
    if (a[i] != '$') {
      path += a[i].toLowerCase();
    }
  }
  if (a[0] == '$' && len == 2) {
    path += "\\" + a[1];
  }
  path += ".asp";
  eval(include(path));
}

/**
 * Ensures the variable is defined
 * @param  v  the variable name
 * @return boolean
 */
function defined(v) {
  return typeof v != "undefined";
}

/**
 * Ensures the variable type is array
 * @param  v  the variable name
 * @return boolean
 */
function isArray(v) {
  return Array.prototype.isPrototypeOf(v);
}

/**
 * Ensures the variable type is boolean
 * @param  v  the variable name
 * @return boolean
 */
function isBool(v) {
  return typeof v == "boolean";
}

/**
 * Ensures the variable type is date
 * @param  v  the variable name
 * @return boolean
 */
function isDate(v) {
  return (typeof v == "date" || Date.prototype.isPrototypeOf(v));
}

/**
 * Ensures the variable type is function
 * @param  v  the variable name
 * @return boolean
 */
function isFunction(v) {
  return typeof v == "function";
}

/**
 * Ensures the variable type is number
 * @param  v  the variable name
 * @return boolean
 */
function isNumber(v) {
  return typeof v == "number";
}

/**
 * Ensures the variable is numeric
 * @param  str  the string variable
 * @return boolean
 */
function isNumeric(str) {
  return /^[\+\-]?\d+\.?\d*$/.test(str);
}

/**
 * Ensures the variable type is object
 * @param  v  the variable name
 * @return boolean
 */
function isObject(v) {
  return typeof v == "object";
}

/**
 * Ensures the variable type is string
 * @param  v  the variable name
 * @return boolean
 */
function isString(v) {
  return typeof v == "string";
}

/**
 * Ensures server object exist
 * @param  str  the object string name
 * @return boolean
 */
function objectExists(str) {
  try {
    Server.CreateObject(str);
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * Extend an object
 * @param  obj   the object to extend
 * @param  base  the object to extend from
 * @return void
 */
function extend(obj, base) {
  if (isFunction(base)) {
    obj.__base__ = base;
    obj.__base__();
    delete obj.__base__;
  } else {
    for (m in base) {
      obj[m] = base[m];
    }
  }
}

/**
 * Serialize an object to javascript definition
 * @param  obj    the object to serialize
 * @param  name   [optional]the variable name for definition
 * @param  isvar  [optional]whether to use var for definition
 * @return string
 */
function serialize(obj, name, isvar) {
  var s = "";
  if (!defined(isvar) || isvar == true) {
    s += "var ";
  }
  if (defined(name)) {
    s += name + " = ";
  }
  if (obj == null) {
    s += "null";
  } else if(isArray(obj)) {
    var len = obj.length;
    if (defined(name)) {
      s += "new Array();";
      for (key in obj) {
        s += name + "[";
        if (isString(key)) {
          s += "\"" + key + "\"";
        } else {
          s += key;
        }
        s += "] = " + serialize(obj[key]) + ";";
      }
    } else if (len > 0) {
      var first = false;
      s += "new Array(";
      for (i = 0; i < len; i++) {
        if (first) {
          s += ", ";
        } else {
          first = true;
        }
        s += serialize(obj[i]);
      }
      s += ")";
    }
  } else if (isObject(obj)) {
    s += "{";
    var first = false;
    for (k in obj) {
      if (first) {
        s += ", ";
      } else {
        first = true;
      }
      s += "\"" + k + "\"" + ": ";
      s += serialize(obj[k]);
    }
    s += "}";
  } else if (isFunction(obj)) {
    s = obj.toString();
  } else if (isString(obj)) {
    s += "\"" + obj.replace(/"/, "\\\"") + "\"";
  } else {
    s += obj;
  }
  if (defined(name) && /[^;]$/.test(s)) {
    s += ";";
  }

  return s;
}

/**
 * Get GET variables
 * @param  str  the string variable
 * @return string|array
 */
function TGet(str) {
  var len = Request.QueryString(str).Count;
  if (len > 1) {
    var a = new Array(len);
    for (i = 0; i < len; i++) {
      a[i] = Request.QueryString(str).Item(i + 1);
    }
    return a;
  } else {
    return Request.QueryString(str).Item(1);
  }
}

/**
 * Get POST variables
 * @param  str  the string variable
 * @return string|array
 */
function TPost(str) {
  if (isMultiData) {
    if (!defined(myRequest.forms[str])) {
      return "";
    }
    return myRequest.forms[str];
  } else {
    var len = Request.Form(str).Count;
    if (len > 1) {
      var a = new Array(len);
      for (i = 0; i < len; i++) {
        a[i] = Request.Form(str).Item(i + 1);
      }
      return a;
    } else {
      if (Request.Form(str).Count == 0) {
        return "";
      }
      return Request.Form(str).Item(1);
    }
  }
}

/**
 * Get server variables
 * @param  str  the string variable
 * @return string
 */
function TServer(str) {
  if (Request.ServerVariables(str).Count == 0) {
    return "";
  }
  return Request.ServerVariables(str).Item(1);
}

/**
 * Remove start and end blank characters
 * @return string
 */
String.prototype.trim = function() {
  return this.replace(/(^\s*)|(\s*$)/g, "");
}

/**
 * Remove start blank characters
 * @return string
 */
String.prototype.ltrim = function() {
  return this.replace(/^\s*/g, "");
}

/**
 * Remove end blank characters
 * @return string
 */
String.prototype.rtrim = function() {
  return this.replace(/\s*$/g, "");
}

/**
 * Format date, default yyyy-mm-dd HH:MM:SS
 * @param  str  [optional]the date format
 * @return string
 */
Date.prototype.format = function(str) {
  var year = this.getYear();
  var month = this.getMonth();
  var day = this.getDate();
  var hour = this.getHours();
  var minute = this.getMinutes();
  var second = this.getSeconds();
  var d = defined(str) ? str : "yyyy-mm-dd HH:MM:SS";
  if (/yyyy/.test(d)) {
    d = d.replace("yyyy", year);
  } else {
    d = d.replace("yy", year.substr(2, 2));
  }
  if (/mm/.test(d)) {
    d = d.replace("mm", (month < 10) ? ("0" + month) : month);
  } else {
    d = d.replace("m", month);
  }
  if (/dd/.test(d)) {
    d = d.replace("dd", (day < 10) ? ("0" + day) : day);
  } else {
    d = d.replace("d", day);
  }
  if (/HH/.test(d)) {
    d = d.replace("HH", (hour < 10) ? ("0" + hour) : hour);
  } else {
    d = d.replace("H", hour);
  }
  if (/MM/.test(d)) {
    d = d.replace("MM", (minute < 10) ? ("0" + minute) : minute);
  } else {
    d = d.replace("M", minute);
  }
  if (/SS/.test(d)) {
    d = d.replace("SS", (second < 10) ? ("0" + second) : second);
  } else {
    d = d.replace("S", second);
  }
  
  return d;
}

/**
 * Convert to date type to string
 * @param  str  [optional]the date format
 * @return string
 */
Date.prototype.toString = function(str) {
  return this.format(str);
}
%>