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
 * @package   Template
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

/**
 * Class Template
 */
function Template() {
  this.content = "";
  this.vList = new Array();
  this.file = "";
  this.vList["LBrace"] = "{";
  this.vList["RBrace"] = "}";
}

Template.prototype = {

  /**
   * Add a variable for replacement
   * @param  name  the variable name
   * @param  value the variable value
   * @return void
   */
  assign: function(name, value) {
    this.vList[name] = value;
  },

  /**
   * Add the data to the template
   * @param  data  the string to add
   * @return void
   */
  add: function(data) {
    this.content += data;
  },

  /**
   * Add a file to the template
   * @param  path  the file to add
   * @return void
   */
  addFile: function(path) {
    this.content += $.File.readFile(path);
  },

  /**
   * Display the template
   * @return void
   */
  display: function() {
    if (this.content.indexOf("<%") > -1) {
      this.execute();
    }
    // Add filters
    this.addListFilter();
    var data = this.eval(this.content);
    if (this.file != "") {
      $.File.writeFile(this.file, data);
    }
    echo(data);
  },

  /**
   * Create a cache file while displaying the template
   * @param  path  the path of the file
   * @return void
   */
  setCache: function(path) {
    this.file = path;
  },

  /**
   * Replace the template variables
   * @param  data  the data to replace
   * @param  arr   [optional]the array variables for replacement
   * @return string
   */
  eval: function(data, arr) {
    var matches = data.match(/\{[^\}]+\}/ig);
    if (matches) {
      var len = matches.length;
      var name, value, exec, code;
      for (i = 0; i < len; i++) {
        name = matches[i].substr(1, matches[i].length - 2);
        value = "";
        exec = false;
        if (/^[a-z0-9\$\._]+$/.test(name)) {
          if (/^\$/.test(name)) {
            exec = true;
          } else if (defined(arr) && defined(arr[name])) {
            value = arr[name];
          } else if (defined(this.vList[name])) {
            value = this.vList[name];
          } else if (name.indexOf(".") > -1) {
            var a = name.split(".", 2);
            if (defined(arr) && defined(arr[a[0]])) {
              name = "arr[\"" + a[0] + "\"]." + a[1];
              exec = true;
            } else if (defined(this.vList[a[0]])) {
              name = "this.vList[\"" + a[0] + "\"]." + a[1];
              exec = true;
            }
          }
        } else {
          var m = name.match(/\$\([a-z0-9\$\._]+\)/ig);
          if (m) {
            var len2 = m.length;
            for (j = 0; j < len2; j++) { 
              var v = m[j].substr(2, m[j].length - 3);
              if (defined(arr) && defined(arr[v])) {
                v = "arr[\"" + v + "\"]";
              } else if (defined(this.vList[v])) {
                v = "this.vList[\"" + v + "\"]";
              } else if (v.indexOf(".") > -1) {
                var a = v.split(".", 2);
                if (defined(arr) && defined(arr[a[0]])) {
                  v = "arr[\"" + a[0] + "\"]." + a[1];
                } else if (defined(this.vList[a[0]])) {
                  v = "this.vList[\"" + a[0] + "\"]." + a[1];
                }
              }
              name = name.replace(m[j], v);
            }
          }
          exec = true;
        }
        if (exec) {
          try {
            code = defined($.View) ? "with ($.View.Helper) {" + name + "}" : name;
            value = eval(code);
          } catch (e) {
            value = "";
          }
        }
        data = data.replace(matches[i], value);
      }
    }

    return data;
  },

  /**
   * Execute ASP code in the template
   * @return void
   */
  execute: function() {
    var tagStart, tagEnd, code, buffer;
    code = "";
    buffer = ""
    tagEnd = 0;
    tagStart = this.content.indexOf("<%") + 2;
    var write_buffer = function(data) {
      buffer += data;
    };
    var write_line_buffer = function(data) {
      buffer += data + "\n";
    };
    var write_html_code = function(data) {
      var str = data.replace(/\s+$/, "");
      str = str.replace(/\r?\n/g, "\\n");
      str = str.replace(/'/g, "\\'");
      code += "write_line_buffer('" + str + "');\n";
    };
    try {
      while (tagStart - tagEnd > 1) {
        if (tagStart - tagEnd > 2) {
          write_html_code(this.content.substring(tagEnd, tagStart - 2));
        }
        tagEnd = this.content.indexOf("%\>", tagStart) + 2;
        str = this.content.substring(tagStart, tagEnd - 2);
        if (str.match(/^\s*=/)) {
          str = str.replace(/^\s*=(.*)/, "$1");
          code += "write_buffer(" + str + ");";
        } else {
          str = str.replace(/echo\(/g, "write_buffer(");
          str = str.replace(/print\(/g, "write_buffer(");
          str = str.replace(/println\(/g, "write_line_buffer(");
          str = str.replace(/Response.Write\(/ig, "write_buffer(");
          code += str + "\n";
        }
        tagStart = this.content.indexOf("<%", tagEnd) + 2;
      }
      if (tagEnd < this.content.length) {
        write_html_code(this.content.substr(tagEnd));
      }
      code = defined($.View) ? "with ($.View.Helper) {" + code + "}" : code;
      eval(code);
    } catch (e) {
      die("Execute view of " + $.controller + "/" + $.action + " failed" + "<br />\n" + e.description);
    }
    this.content = buffer;
  },

  /**
   * Filter for asp:content tag
   * @param  path    the view template path
   * @param  layout  the layout of the view
   * @return void
   */
  addContentFilter: function(path, layout) {
    var layout_path = APPPATH + "views\\layout\\" + layout + "." + CONFIG["template_extension"];
    if (!$.File.isFile(layout_path)) {
      die("The layout " + layout_path + " not found");
    }
    var data = $.File.readFile(layout_path);
    var str = $.File.readFile(path);
    var a = new Array();
    var tagStart = str.indexOf("<asp:content ");
    var tagEnd = 0;
    var idStart, idEnd, id;
    while (tagStart > -1) {
      tagEnd = str.indexOf("</asp:content>", tagStart);
      idStart = str.indexOf('"', tagStart) + 1;
      idEnd = str.indexOf('"', idStart);
      id = str.substring(idStart, idEnd);
      a[id] = str.substring(tagStart, tagEnd).replace(/^<[^>]+>[ \t\r]*\n?[ \t]*/, "");
      a[id] = a[id].replace(/\r?\n[ \t]*$/, "");
      tagStart = str.indexOf("<asp:content ", tagEnd + 14);
    }
    while ((m = data.match(/<asp:content id="([A-Za-z0-9]+)">\s*<\/asp:content>/))) {
      if (!defined(a[m[1]])) {
        data = data.replace(m[0], "");
      } else {
        data = data.replace(m[0], a[m[1]]);
      }
    }
    this.content = data;
  },

  /**
   * Filter for asp:list tag
   * @return void
   */
  addListFilter: function() {
    var tagStart = this.content.indexOf("<asp:list ");
    var tagEnd = 0;
    if (tagStart == -1) return;
    var data = this.content.substring(0, tagStart);
    var dataStart, str, obj, m, content, a;
    while (tagStart > -1) {
      tagEnd = this.content.indexOf("</asp:list>", tagStart);
      dataStart = this.content.indexOf(">", tagStart) + 1;
      str = this.content.substring(tagStart, dataStart);
      obj = item = value = "";
      m = str.match(/ var="([^"]+)"/);
      if (m) {
        if (defined(this.vList[m[1]])) {
          obj = this.vList[m[1]];
        }
      }
      m = str.match(/ item="([^"]+)"/);
      if (m) {
        item = m[1];
      }
      m = str.match(/ value="([^"]+)"/);
      if (m) {
        value = m[1];
      }
      if (obj != "") {
        if (item == "") {
          item = "item";
        }
        if (value == "") {
          value = "object";
        }
        content = this.content.substring(dataStart, tagEnd);
        a = new Array();
        for (key in obj) {
          a[item] = key;
          a[value] = obj[key];
          data += this.eval(content, a);
        }
      }
      tagStart = this.content.indexOf("<asp:list ", tagEnd + 11);
      if (tagStart > -1) {
        data += this.content.substring(tagEnd + 11, tagStart);
      } else {
        data += this.content.substr(tagEnd + 11);
      }
    }
    this.content = data;
  }

}

$.Template = function() {
  return new Template();
}
%>