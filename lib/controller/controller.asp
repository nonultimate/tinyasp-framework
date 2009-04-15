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
 * @package   Controller
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "view\\view.asp"));

$.Controller = function(obj) {
  return new Controller(obj);
}

/**
 * Class Controller
 */
function Controller(obj) {
  $.view = $.View();

  /**
   * Default index action
   */
  this.index = function() {
    echo("This is a default index action");
  };

  if (defined(obj)) {
    extend(this, obj);
  }
}
%>