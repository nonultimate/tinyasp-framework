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
 */
function timer() {
  return (new Date()).getTime();
}

/**
 * Output string
 */
function echo(str) {
  Response.Write(str);
}

/**
 * Output string
 */
function print(str) {
  echo(str);
}

/**
 * Output string and change line
 */
function println(str) {
  echo(str + "\n");
}

/**
 * Output string and exit
 */
function die(str) {
	Response.Write(str);
	Response.End;
}

/**
 * Output a object or variable
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
 */
function transfer(url) {
  Server.Transfer(url);
}

/**
 * Set HTTP content type
 */
function setContentType(type) {
  Response.ContentType = type;
}

/**
 * Set the time the page expires
 */
function setExpires(time) {
  Response.Expires = time;
}

/**
 * Set HTTP header
 */
function setHeader(name, value) {
  Response.AddHeader(name, value);
}

/**
 * Get the parent directory path
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
 */
function encodeHTML(str) {
  return Server.HTMLEncode(str);
}

/**
 * Encode URL string
 */
function encodeURL(str) {
  return Server.URLEncode(str);
}

/**
 * Format the number as size with 'B', 'KB', 'MB', 'GB'
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
 */
function ucfirst(str) {
  return str.substr(0, 1).toUpperCase() + str.substr(1);
}

/**
 * First letter of each word upper case
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
 * @param  once      whether the file can be included only once, default is true.
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
 */
function defined(v) {
  return typeof v != "undefined";
}

/**
 * Ensures the variable type is boolean
 */
function isBool(v) {
  return typeof v == "boolean";
}

/**
 * Ensures the variable type is number
 */
function isNumber(v) {
  return typeof v == "number";
}

/**
 * Ensures the variable is numeric
 */
function isNumeric(str) {
  return str.search(/^[\+\-]?\d+\.?\d*$/) == 0;
}

/**
 * Ensures the variable type is string
 */
function isString(v) {
  return typeof v == "string";
}

/**
 * Ensures the variable type is object
 */
function isObject(v) {
  return typeof v == "object";
}

/**
 * Ensures the variable type is function
 */
function isFunction(v) {
  return typeof v == "function";
}

/**
 * Ensures the variable type is array
 */
function isArray(v) {
  return Array.prototype.isPrototypeOf(v);
}

/**
 * Ensures server object exist
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
 * Get GET variables
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
 */
String.prototype.ltrim = function() {
  return this.replace(/^\s*/g, "");
}

/**
 * Remove end blank characters
 */
String.prototype.rtrim = function() {
  return this.replace(/\s*$/g, "");
}

/**
 * Format date
 */
Date.prototype.format = function(str) {
  var year = this.getYear();
  var month = this.getMonth();
  var day = this.getDate();
  var hour = this.getHours();
  var minute = this.getMinutes();
  var second = this.getSeconds();
  var f = str ? str : "%Y-%m-%j %H:%M:%S";
  var d = f;
  d = d.replace("%H", hour);
  d = d.replace("%j", day);
  d = d.replace("%m", month);
  d = d.replace("%M", minute);
  d = d.replace("%S", second);
  d = d.replace("%y", year % 100);
  d = d.replace("%Y", year);

  return d;
}
%>