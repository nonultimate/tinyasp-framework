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
 * @package   Cookie
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

$.Cookie = {

  /**
   * Get a cookie
   * @param  name  the cookie name to get
   * @return string
   */
  get: function(name) {
    var len = Request.Cookies(name).Count;
    if (len > 0) {
      var a = new Array(len);
      for (i = 1; i <= len; i++) {
        a[Request.Cookies(name).Key(i)] = Request.Cookies(name).Item(i);
      }
      return a;
    } else {
      return Request.Cookies(name)();
    }
  },

  /**
   * Set a cookie
   * @param  name   the name of the cookie
   * @param  value  the value of the cookie
   * @param  expire [optional]seconds expires from now
   * @param  path   [optional]the path in the server the cookie will be available
   * @param  domain [optional]the domain that the cookie will be available
   * @param  secure [optional]the cookies should only be transmitted over HTTPS
   * @return void
   */
  set: function(name, value, expire, path, domain, secure) {
    if (typeof value != "string") {
      for (key in value) {
        Response.Cookies(name)(key) = value[key];
      }
    } else {
      Response.Cookies(name) = value;
    }
    if (expire) {
      var d = new date();
      d.setSeconds(expire);
      Response.Cookies(str).Expires = d.format();
    }
    if (path) {
      Response.Cookies(name).Path = path;
    }
    if (domain) {
      Response.Cookies(name).Domain = domain;
    }
    if (secure) {
      Response.Cookies(name).Secure = secure;
    }
  },

  /**
   * Remove a cookie
   * @param  name  the cookie name to remove
   * @return void
   */
  remove: function(name) {
    Response.Cookies(str) = "";
    // Set past date to delete cookie
    Response.Cookies(name).Expires = "1-1-1";
  },

  /**
   * Remove all cookies
   * @return void
   */
  removeAll: function() {
    var len = Request.Cookies.Count;
    for (i = 1; i <= len; i++) {
      Response.Cookies.Item(i) = "";
      Response.Cookies.Item(i).Expires = "1-1-1";
    }
  }

}
%>