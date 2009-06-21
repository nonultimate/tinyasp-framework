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
 * @package   Text
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

//eval(include(APPLIB + "text\\deflate.asp"));
//eval(include(APPLIB + "text\\inflate.asp"));

$.Text = {

  /**
   * Compress the data using deflate
   * @param  data  the data to compress
   * @return string
   */
  deflate: function(data) {
     return zip_deflate(data);
  },

  /**
   * Decompress the data using inflate
   * @param  data  the data to decompress
   * @return string
   */
  inflate: function(data) {
    return zip_inflate(data);
  }

}
%>