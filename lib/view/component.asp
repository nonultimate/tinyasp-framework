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
 * @package   View
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

View.prototype.Component = {

  /**
   * The data for replacing component
   */
  data: "",

  /**
   * Filter for tag asp:content
   * @param  path         the view template path
   * @param  layout_path  the view layout path
   * @return void
   */
  addContentFilter: function(path, layout_path) {
    var data = $.File.readFile(layout_path);
    var str = $.File.readFile(path);
    var a = new Array();
    var tagStart = str.indexOf("<asp:content ");
    var tagEnd = 0;
    while (tagStart > -1) {
      tagEnd = str.indexOf("</asp:content>", tagStart);
      var idStart = str.indexOf('"', tagStart) + 1;
      var idEnd = str.indexOf('"', idStart);
      var id = str.substring(idStart, idEnd);
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
    this.data = data;
  },

  /**
   * Get the content handled by filters
   * @param  path   the view template path
   * @param  layout the layout of the view
   * @return string
   */
  getContent: function(path, layout) {
    if (layout) {
      var layout_path = APPPATH + "views\\layout\\" + layout + "." + CONFIG["template_extension"];
      if (!$.File.isFile(layout_path)) {
        die("The layout " + layout_path + " not found");
      }
      // Add content filter
      this.addContentFilter(path, layout_path);
    } else {
      this.data = $.File.readFile(path);
    }
    // Add other filters

    return this.data;
  }

}
%>