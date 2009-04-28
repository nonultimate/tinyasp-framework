<!--#include file="include/functions.asp"-->
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
 * @package   Tinyasp
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "include\\ado.asp"));

var $ = {

  name: "Tinyasp Framework",

  version: "0.1 beta3",

  copyright: "Copyright (c) 2008-2009 Joe Dotoff",

  isGet: false,

  isPost: false,

  isMultiPost: false,

  get: null,

  post: null,

  server: null,

  files: null,

  /**
   * Setup runtime configuration
   * @return void
   */
  config: function() {
    eval(include(APPLIB + "file\\file.asp"));
    // Load configuration
    if ($.File.isFile(APPPATH + "config\\config.asp")) {
      eval(include(APPPATH + "config\\config.asp"));
    }
    // Load router
    if ($.File.isFile(APPPATH + "config\\router.asp")) {
      eval(include(APPPATH + "config\\router.asp"));
    }
    // Set environment
    if (CONFIG["buffer"]) {
      Response.Buffer = true;
    }
    Response.Charset = CONFIG["charset"];
    // Get codepage of the charset
    switch (CONFIG["charset"].toLowerCase()) {
      case "ansi":
      case "windows-1250": codepage = 1250;break;
      case "big5": codepage = 950;break;
      case "gb18030": codepage = 54936;break;
      case "gb2312":
      case "gbk": codepage = 936;break;
      case "euc-jp": codepage = 51932;break;
      case "euc-kr": codepage = 51949;break;
      case "iso-8859-1": codepage = 28591;break;
      case "iso-8859-2": codepage = 28592;break;
      case "iso-8859-3": codepage = 28593;break;
      case "iso-8859-4": codepage = 28594;break;
      case "iso-8859-5": codepage = 28595;break;
      case "iso-8859-6": codepage = 28596;break;
      case "iso-8859-7": codepage = 28597;break;
      case "iso-8859-8": codepage = 28598;break;
      case "iso-8859-9": codepage = 28599;break;
      case "iso-8859-13": codepage = 28603;break;
      case "iso-8859-15": codepage = 28605;break;
      case "kio8-r": codepage = 20866;break;
      case "kio8-u": codepage = 21866;break;
      case "ks_c_5601-1987": codepage = 949;break;
      case "shift-jis": codepage = 932;break;
      case "unicode": codepage = 1200;break;
      case "utf-7": codepage = 65000;break;
      case "utf-8": codepage = 65001;break;
      case "windows-874": codepage = 874;break;
      case "windows-1251": codepage = 1251;break;
      case "windows-1252": codepage = 1252;break;
      case "windows-1253": codepage = 1253;break;
      case "windows-1254": codepage = 1254;break;
      case "windows-1255": codepage = 1255;break;
      case "windows-1256": codepage = 1256;break;
      case "windows-1257": codepage = 1257;break;
      case "windows-1258": codepage = 1258;break;
    }
    if (defined(codepage)) {
      Session.CodePage = codepage;
    }
  },

  /**
   * Initialize variables
   * @return void
   */
  init: function() {
    var myRequest;

    $.get = function() {
      var len = Request.QueryString.Count;
      var a = new Array(len);
      for (i = 1; i <= len; i++) {
        if (Request.QueryString.Item(i).Count > 1) {
          var k = Request.QueryString.Item(i).Count;
          var b = new Array(k);
          for (j = 0; j < k; j++) {
            b[j] = Request.QueryString.Item(i).Item(j + 1);
          }
          a[Request.QueryString.Key(i)] = b;
        } else {
          a[Request.QueryString.Key(i)] = Request.QueryString.Item(i).Item(1);
        }
      }

      return a;
    }();

    $.server = function() {
      var len = Request.ServerVariables.Count;
      var a = new Array(len + 2);
      for (i = 1; i <= len; i++) {
        a[Request.ServerVariables.Key(i)] = Request.ServerVariables.Item(i).Item(1);
      }
      a["REQUEST_URI"] = Request.ServerVariables("SCRIPT_NAME").Item(1);
      if (Request.ServerVariables("QUERY_STRING").Item(1) != "") {
        a["REQUEST_URI"] += "?" + Request.ServerVariables("QUERY_STRING").Item(1);
      }
      var protocol = Request.ServerVariables("HTTPS").Item(1).toLowerCase() == "on" ? "https://" : "http://";
      a["REQUEST_URL"] = protocol + Request.ServerVariables("HTTP_HOST").Item(1) + a["REQUEST_URI"];

      return a;
    }();

    if ($.server["REQUEST_METHOD"] == "GET") {
      $.isGet = true;
    } else if($.server["REQUEST_METHOD"] == "POST") {
      $.isPost = true;
      // Dealing post data of content type "multipart/form-data"
      if ($.server["CONTENT_TYPE"].match(/multipart\/form-data;/i)) {
        $.isMultiPost = true;
        eval(include(APPLIB + "include\\formhelper.asp"));
        myRequest = new FormHelper();
      }
    }

    $.post = function() {
      if ($.isMultiPost) {
        return myRequest.forms;
      } else {
        var len = Request.Form.Count;
        var a = new Array(len);
        for (i = 1; i <= len; i++) {
          if (Request.Form.Item(i).Count > 1) {
            var k = Request.Form.Item(i).Count;
            var b = new Array(k);
            for (j = 0; j < k; j++) {
              b[j] = Request.Form.Item(i).Item(j + 1);
            }
            a[Request.Form.Key(i)] = b;
          } else {
            a[Request.Form.Key(i)] = Request.Form.Item(i).Item(1);
          }
        }

        return a;
      }
    }();

    $.files = function() {
      if ($.isMultiPost) {
        return myRequest.files;
      }

      return new Array();
    }();
  },

  /**
   * Run the appliaction
   * @return void
   */
  run: function() {
    // Setup configuration
    this.config();
    this.init();

    // Define variables
    var str = this.get["q"] || "";
    // Load router and rewrite URL
    if (str != "" && defined(CONFIG["router"])) {
      for (v in CONFIG["router"]) {
        re = new RegExp("^" + v, "i");
        if (re.test(str)) {
          str = str.replace(re, CONFIG["router"][v]);
          break;
        }
      }
    }
    var a = str.split(/[\/]+/);
    var controller = "";
    var action = "";
    var param = new Array();
    if (a.length > 2) {
      param.length = a.length - 2;
      for (i = 0; i + 2 < a.length; i++) {
        param[i] = a[i + 2];
      }
    }
    if (a.length > 1) {
      action = a[1].toLowerCase();
    }
    if (a.length > 0) {
      controller = a[0].toLowerCase();
    }

    // Include Router
    eval(include(APPLIB + "router\\router.asp"));

    // Create a router to deal with the action
    $.Router(controller, action, param);
  }

}
%>