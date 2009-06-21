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

$.View.Helper = {

  /**
   * Get the current URL
   * @return string
   */
  url: function() {
    var url = "/" + $.query;
    var str = $.server["QUERY_STRING"].replace(/^q=[^&]*&?/, "");
    if (str != "") {
      url += "?" + str;
    }

    return url;
  },

  /**
   * Validate the post data, return true if it is empty
   * @param  v  the post variable
   * @return boolean
   */
  validate: function(v) {
    return $.isPost && empty(v);
  },

  /**
   * Pager view helper
   * @param  obj  the pager object
   * @return string
   */
  pager: function(obj) {
    if (obj.page == 1) {
      return "";
    }
    var str = '<div class="pager">';
    var linkStr = obj.getLinkStr();
    var start = (obj.current - 5 > 0) ? (obj.current - 5) : 1;
    var end = ((obj.current + 4) < obj.page) ? (obj.current + 4) : obj.page;
    for (var i = start; i <= end; i++) {
      if (i == obj.current) {
        str += '<span>' + i + '</span>';
      } else {
        str += '<a href="' + linkStr.replace(/\{N\}/, i) + '">' + i + '</a>';
      }
    }
    str += '</div>';

    return str;
  }

}
%>