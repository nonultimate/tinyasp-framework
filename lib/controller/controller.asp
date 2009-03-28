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
 * @package   Controller
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 * @version   $Id: controller.asp 40 2009-02-14 07:19:06Z joe $
 */

eval(include(APPLIB + "action\\action.asp"));

$.Controller = function() {
  return new Controller();
}

/**
 * Class Controller
 */
function Controller() {
  this.action = Action;
  this.action();
}
%>