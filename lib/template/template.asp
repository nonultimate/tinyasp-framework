<%
/**
 * Tinyasp Framework
 *
 * This source file is subject to the new BSD license that is bundled
 * with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://www.tinyasp.org/license/LICENSE.txt
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to nonultimate@gmail.com so we can send you a copy immediately.
 *
 * @package   Template
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 * @version   $Id: template.asp 71 2009-03-17 02:19:41Z joe $
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
   * Create a template file
   * @param  path  the path of the file
   * @return boolean
   */
  createTemplate: function(path) {
    return $.File.writeFile(path, this.content);
  },

  /**
   * Display the template
   * @return void
   */
  display: function() {
    data = this.content;
    matches = data.match(/\{[a-z0-9\$\._-]+\}/ig);
    if (matches) {
      var len = matches.length;
      for (i = 0; i < len; i++) {
        name = matches[i].substr(1, matches[i].length - 2);
        value = null;
        if (defined(this.vList[name])) {
          value = this.vList[name];
        } else {
          if (name.indexOf(".") > -1) {
            a = name.split(".", 2);
            if (defined(this.vList[a[0]])) {
              name = "this.vList[\"" + a[0] + "\"]." + a[1];
            }
          }
          try {
            value = eval(name);
          } catch (e) {
            value = "";
          }
        }
        if (!defined(value)) {
          value = "";
        }
        //if (value != null) {
          data = data.replace(matches[i], value);
        //}
      }
    }
    if (data.indexOf("<%") > -1) {
      data = this.execute(data);
    }
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
   * Execute ASP code in the template
   * @param  content  the code in the template to execute
   * @return string
   */
  execute: function(content) {
    var tagStart, tagEnd, code;
    code = "";
    tagEnd = 0;
    tagStart = content.indexOf("<%") + 2;
    try {
      while (tagStart - tagEnd > 1) {
        if (tagStart - tagEnd > 2) {
          code += content.substring(tagEnd, tagStart - 2);
        }
        tagEnd = content.indexOf("%\>", tagStart) + 2;
        str = content.substring(tagStart, tagEnd - 2);
        if (str.match(/^\s*=/)) {
          str = str.replace(/^\s*=(.*)/, "$1");
          code += eval(str);
        } else {
          if(str.match(/echo\(/) || str.match(/Response.Write\(/i)) {
            var a = str.split("\n");
            var len = a.length;
            for (i = 0; i < len; i++) {
              if (a[i].match(/echo\(/)) {
                str = a[i].replace(/echo\(/, "");
                str = str.replace(/\);?\s*$/, "");
                code += eval(str);
              } else if(a[i].match(/Response.Write\(/i)) {
                str = a[i].replace(/Response.Write\(/i, "");
                str = str.replace(/\);?\s*$/, "");
                code += eval(str);
              } else {
                eval(a[i]);
              }
            }
          } else {
            eval(str);
          }
        }
        tagStart = content.indexOf("<%", tagEnd) + 2;
      }
      if (tagEnd < content.length) {
        code += content.substr(tagEnd);
      }
    } catch (e) {
      die("Execute view of " + $.controller + "/" + $.action + " failed");
    }

    return code;
  }

}

$.Template = function() {
  return new Template();
}
%>