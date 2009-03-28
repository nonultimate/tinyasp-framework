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
 * @package   Include
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 * @version   $Id: formhelper.asp 72 2009-03-21 00:50:00Z joe $
 */

eval(include(APPLIB + "file\\file.asp"));

/**
 * Form helper for handling multipart/form-data post
 */
function FormHelper() {
  this.size = Request.TotalBytes;
  this.stream = null;
  this.text = "";
  this.forms = new Array();
  this.files = new Array();

  if (this.size > 0) {
    this.read();
  }
}

/**
 * Read post data
 */
FormHelper.prototype.read = function() {
  var binData = Request.BinaryRead(this.size);
  this.stream = Server.CreateObject("ADODB.Stream");
  this.stream.Type = adTypeText;
  this.stream.Open();
  this.stream.WriteText(binData);
  this.stream.Position = 0;
  this.stream.Charset = CONFIG["charset"];
  this.stream.Position = 2;
  this.text = this.stream.ReadText();

  var boundary = "--" + TServer("CONTENT_TYPE").replace(/(.*)boundary=/, "");
  var bLen = boundary.length;
  var start = bLen + 2;
  var end;

  while (start > 0) {
    end = this.text.indexOf(boundary, start);
    if (end < 0) {
      break;
    }
    str = this.text.substring(start, end - 2);
    start = this.text.indexOf(boundary, end);
    if (start > 0) {
      start += bLen + 2;
    }
    sep = str.indexOf("\r\n\r\n");
    header = str.substring(0, sep);
    data = str.substr(sep + 4);
    m = header.match(/Content-Disposition: form-data; name="([^"]*)"(; filename="([^"]+)")?/i);
    if (m) {
      item = m[1];
      if (m[3] != "") {
        filename = m[3];
        filetype = "";
        m = header.match(/Content-Type: ([^\r\n]+)/i);
        if (m) {
          filetype = m[1];
        }
        a = new Array(3);
        a["name"] = filename;
        a["type"] = filetype;
        a["size"] = data.length;
        a["path"] = APPPATH + "tmp\\" + timer() + Math.random().toString().substr(2);
        this.files[item] = a;
        this.files.length += 1;
        $.File.writeFile(a["path"], data);
      } else {
        if (!defined(this.forms[item])) {
          this.forms[item] = data;
          this.forms.length += 1;
        } else if (isString(this.forms[item])) {
          this.forms[item] = new Array(this.forms[item], data);
        } else {
          this.forms[item].push(data);
        }
      }
    }
  }
}
%>