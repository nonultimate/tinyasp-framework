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
 * @package   Net
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "net\\net.asp"));

$.Net.Http = {

  /**
   * XMLHTTP object
   */
  req: Server.CreateObject("Microsoft.XMLHTTP"),

  /**
   * Get the data in HTTP GET method
   * @param  url  the URL to open
   * @return string
   */
  get: function(url) {
    this.req.open("GET", url, false);
    this.req.send();
    return this.req.responseText;
  },

  /**
   * Post the data in HTTP POST method
   * @param  url  the URL to open
   * @param  data the data to send
   * @return string
   */
  post: function(url, data) {
    this.req.open("POST", url, false);
    this.req.send(data);
    return this.req.responseText;
  }

};
%>