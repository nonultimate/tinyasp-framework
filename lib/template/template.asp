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

eval(include(APPLIB + "file\\file.asp"));

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
    this.addIncludeFilter();
    this.addPagerFilter();
    this.addIfFilter();
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
      for (var i = 0; i < len; i++) {
        name = matches[i].substr(1, matches[i].length - 2);
        value = null;
        exec = false;
        if (/^[A-Za-z0-9\$\._]+$/.test(name)) {
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
            for (var j = 0; j < len2; j++) { 
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
            if (/^[A-Za-z0-9\$\._]+$/.test(name)) {
              value = "";
            }
          }
        }
        if (value != null) {
          data = data.replace(matches[i], value);
        }
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
      error("Execute view of " + $.controller + "/" + $.action + " failed", e);
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
      error("The layout " + layout_path + " not found");
    }
    var data = $.File.readFile(layout_path);
    var str = $.File.readFile(path);
    var a = new Array();
    var tagStart = str.indexOf("<asp:content ");
    var tagEnd = 0;
    var idStart, idEnd, id, m;
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
   * Filter for asp:include tag
   * @return void
   */
  addIncludeFilter: function() {
    var tagStart = this.content.indexOf("<asp:include ");
    var tagEnd = 0;
    if (tagStart == -1) {
      return;
    }
    var data = this.content.substring(0, tagStart);
    var str, m;
    while (tagStart > -1) {
      tagEnd = this.content.indexOf(">", tagStart) + 1;
      var str = this.content.substring(tagStart, tagEnd);
      m = str.match(/ file="([^"]+)"/);
      if (m) {
        data += $.File.readFile(APPPATH + "views\\html\\" + m[1].replace(/\//g, "\\"));
      }
      tagStart = this.content.indexOf("<asp:include ", tagEnd);
      if (tagStart > -1) {
        data += this.content.substring(tagEnd, tagStart);
      } else {
        data += this.content.substr(tagEnd);
      }
    }
    this.content = data;
  },

  /**
   * Filter for asp:if tag
   * @return void
   */
  addIfFilter: function() {
    var tagStart = this.content.indexOf("<asp:if ");
    var tagEnd = 0;
    if (tagStart == -1) {
      return;
    }
    var data = this.content.substring(0, tagStart);
    var dataStart, str, content, result, code, elTagStart, elTagEnd, m, m2, v, s;
    while (tagStart > -1) {
      tagEnd = this.content.indexOf("</asp:if>", tagStart);
      elTagStart = this.content.substring(tagStart, tagEnd).indexOf("<asp:else");
      if (elTagStart > -1) {
        elTagStart += tagStart;
        elTagEnd = this.content.indexOf(">", elTagStart) + 1;
      }
      dataStart = this.content.indexOf(">", tagStart) + 1;
      str = this.content.substring(tagStart, dataStart);
      m = str.match(/ condition="([^"]+)"/);
      if (m) {
        v = m[1];
        m2 = v.match(/\$\([a-z0-9\$\._]+\)/ig);
        if (m2) {
          for (var i = 0; i < m2.length; i++) {
            s = m2[i].substr(2, m2[i].length - 3);
            if (defined(this.vList[s])) {
              v = v.replace(m2[i], "this.vList[\"" + s + "\"]");
            }
          }
        }
        code = defined($.View) ? "with ($.View.Helper) {" + v + "}" : v;
        result = eval(code);
        if (result) {
          result = this.eval(this.content.substring(dataStart, (elTagStart > -1) ? elTagStart : tagEnd));
          data += result.replace(/\{/g, "LBrace").replace(/\}/g, "RBrace");
        } else if(elTagStart > -1) {
          result = this.eval(this.content.substring(elTagEnd, tagEnd));
          data += result.replace(/\{/g, "LBrace").replace(/\}/g, "RBrace");
        }
      }
      tagStart = this.content.indexOf("<asp:if ", tagEnd + 9);
      if (tagStart > -1) {
        data += this.content.substring(tagEnd + 9, tagStart);
      } else {
        data += this.content.substr(tagEnd + 9);
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
    if (tagStart == -1) {
      return;
    }
    var data = this.content.substring(0, tagStart);
    var dataStart, str, obj, item, value, m, content, a, result;
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
          result = this.eval(content, a);
          data += result.replace(/\{/g, "LBrace").replace(/\}/g, "RBrace");
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
  },

  /**
   * Filter for asp:pager tag
   * @return void
   */
  addPagerFilter: function() {
    var tagStart = this.content.indexOf("<asp:pager ");
    var tagEnd = 0;
    if (tagStart == -1) {
      return;
    }
    var data = this.content.substring(0, tagStart);
    var str, m, pager, f;
    while (tagStart > -1) {
      tagEnd = this.content.indexOf(">", tagStart) + 1;
      var str = this.content.substring(tagStart, tagEnd);
      m = str.match(/ var="([^"]+)"/);
      if (m) {
        if (defined(this.vList[m[1]])) {
          pager = this.vList[m[1]];
          m = str.match(/ function="([^"]+)"/);
          if (m) {
            data += eval(m[1] + "(pager)");
          } else {
            data += $.View.Helper.pager(pager);
          }
        }
      }
      tagStart = this.content.indexOf("<asp:pager ", tagEnd);
      if (tagStart > -1) {
        data += this.content.substring(tagEnd, tagStart);
      } else {
        data += this.content.substr(tagEnd);
      }
    }
    this.content = data;
  }

}

$.Template = function() {
  return new Template();
}
%>