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
 * @package   Session
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

$.Session = {

  /**
   * Get the session
   * @param  name  the name of the session
   * @return string
   */
  get: function(name) {
    return Session(name);
  },

  /**
   * Set the session
   * @param  name  the name of the session
   * @param  value the value of the session
   * @return void
   */
  set: function(name, value) {
    Session(name) = value;
  },

  /**
   * Remove the session
   * @param  name  the name of the session
   * @return void
   */
  remove: function(name) {
    Session.Contents.Remove(name);
  },

  /**
   * Remove all the sessions
   * @return void
   */
  removeAll: function() {
    Session.Contents.RemoveAll();
  }

}
%>