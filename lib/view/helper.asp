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
  }

}
%>