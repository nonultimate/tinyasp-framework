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
 * @package   Security
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

//eval(include(APPLIB + "security\\md5.asp"));
//eval(include(APPLIB + "security\\sha1.asp"));

$.Security = {

  /**
   * Encoding text in MD5
   * @param  text  the text to encode
   * @return string
   */
  MD5: function(text) {
    return hex_md5(text);
  },

  /**
   * Encoding text in SHA1
   * @param  text  the text to encode
   * @return string
   */
  SHA1: function(text) {
    return calcSHA1(text);
  }

}
%>