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
 * @package   Text
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 * @version   $Id: base64.asp 40 2009-02-14 07:19:06Z joe $
 */

eval(include(APPLIB + "text\\text.asp"));

$.Text.Base64 = {

  /**
   * Encoding key
   */
  enKey: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',

  /**
   * Decoding key
   */
  deKey: new Array(
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
    -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
    -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1
  ),

  /**
   * Encode string in BASE64
   * @param  src  the stirng to encode
   * @return string
   */
  encode: function(src) {
    var str = new Array();
    var ch1, ch2, ch3;
    var pos = 0;
    while (pos + 3 <= src.length) {
      ch1 = src.charCodeAt(pos++);
      ch2 = src.charCodeAt(pos++);
      ch3 = src.charCodeAt(pos++);
      str.push(this.enKey.charAt(ch1 >> 2), this.enKey.charAt(((ch1 << 4)+(ch2 >> 4)) & 0x3f));
      str.push(this.enKey.charAt(((ch2 << 2) + (ch3 >> 6)) & 0x3f), this.enKey.charAt(ch3 & 0x3f));
    }
    if (pos < src.length) {
      ch1 = src.charCodeAt(pos++);
      str.push(this.enKey.charAt(ch1 >> 2));
      if (pos < src.length) {
        ch2 = src.charCodeAt(pos);
        str.push(this.enKey.charAt(((ch1 << 4)+(ch2 >> 4)) & 0x3f));
        str.push(this.enKey.charAt(ch2 << 2 & 0x3f), '=');
      } else {
        str.push(this.enKey.charAt(ch1 << 4 & 0x3f), '==');
      }
    }
    return str.join('');
  },

  /**
   * Decode the BASE64 string
   * @param  src  the stirng to decode
   * @return string
   */
  decode: function(src) {
    var str = new Array();
    var ch1, ch2, ch3, ch4;
    var pos = 0;
    src = src.replace(/[^A-Za-z0-9\+\/]/g, '');
    while (pos + 4 <= src.length) {
      ch1 = this.deKey[src.charCodeAt(pos++)];
      ch2 = this.deKey[src.charCodeAt(pos++)];
      ch3 = this.deKey[src.charCodeAt(pos++)];
      ch4 = this.deKey[src.charCodeAt(pos++)];
      str.push(String.fromCharCode((ch1 << 2 & 0xff) + (ch2 >> 4), (ch2 << 4 & 0xff) + (ch3 >> 2), (ch3 << 6 & 0xff) + ch4));
    }
    if (pos + 1 < src.length) {
      ch1 = this.deKey[src.charCodeAt(pos++)];
      ch2 = this.deKey[src.charCodeAt(pos++)];
      if (pos < src.length) {
        ch3 = this.deKey[src.charCodeAt(pos)];
        str.push(String.fromCharCode((ch1 << 2 & 0xff) + (ch2 >> 4), (ch2 << 4 & 0xff) + (ch3 >> 2)));
      } else {
        str.push(String.fromCharCode((ch1 << 2 & 0xff) + (ch2 >> 4)));
      }
    }
    return str.join('');
  }

};
%>