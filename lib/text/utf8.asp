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
 * @version   $Id: utf8.asp 40 2009-02-14 07:19:06Z joe $
 */

eval(include(APPLIB + "text\\text.asp"));

$.Text.UTF8 = {

  /**
   * Encode string in UTF8
   * @param  str  the string to encode
   * @return string
   */
  encode: function(str) {
    // http://kevin.vanzonneveld.net
    // +   original by: Webtoolkit.info (http://www.webtoolkit.info/)
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: sowberry
    // +    tweaked by: Jack
    // +   bugfixed by: Onno Marsman
    // +   improved by: Yves Sucaet
    // +   bugfixed by: Onno Marsman
    // *     example 1: utf8_encode('Kevin van Zonneveld');
    // *     returns 1: 'Kevin van Zonneveld'
 
    str= (str + '').replace(/\r\n/g, "\n").replace(/\r/g, "\n");
 
    var utftext = "";
    var start, end;
    var len = 0;
 
    start = end = 0;
    len = str.length;
    for (var n = 0; n < len; n++) {
      var c1 = str.charCodeAt(n);
      var enc = null;

      if (c1 < 128) {
        end++;
      } else if((c1 > 127) && (c1 < 2048)) {
        enc = String.fromCharCode((c1 >> 6) | 192) + String.fromCharCode((c1 & 63) | 128);
      } else {
        enc = String.fromCharCode((c1 >> 12) | 224) + String.fromCharCode(((c1 >> 6) & 63) | 128) + String.fromCharCode((c1 & 63) | 128);
      }
      if (enc != null) {
        if (end > start) {
            utftext += str.substring(start, end);
        }
        utftext += enc;
        start = end = n + 1;
      }
    }
 
    if (end > start) {
      utftext += str.substring(start, len);
    }
 
    return utftext;
  },

  /**
   * Decode the UTF8 string
   * @param  str  the string to decode
   * @return string
   */
  decode: function(str) {
    // http://kevin.vanzonneveld.net
    // +   original by: Webtoolkit.info (http://www.webtoolkit.info/)
    // +      input by: Aman Gupta
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: Norman "zEh" Fuchs
    // +   bugfixed by: hitwork
    // +   bugfixed by: Onno Marsman
    // *     example 1: utf8_decode('Kevin van Zonneveld');
    // *     returns 1: 'Kevin van Zonneveld'

    // Convert str to string
    str += '';

    var arr = [], i = ac = c1 = c2 = c3 = 0;
    var len = str.length;
 
    while (i < len) {
      c1 = str.charCodeAt(i);
      if (c1 < 128) {
        arr[ac++] = String.fromCharCode(c1);
        i++;
      } else if ((c1 > 191) && (c1 < 224)) {
        c2 = str.charCodeAt(i+1);
        arr[ac++] = String.fromCharCode(((c1 & 31) << 6) | (c2 & 63));
        i += 2;
      } else {
        c2 = str.charCodeAt(i+1);
        c3 = str.charCodeAt(i+2);
        arr[ac++] = String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
        i += 3;
      }
    }
 
    return arr.join('');
  },

  /**
   * Convert UTF8 string to UTF16 string
   * @param  str  the string to convert
   * @return string
   */
  toUTF16: function(str) {
    /* utf.js - UTF-8 <=> UTF-16 convertion
     *
     * Copyright (C) 1999 Masanao Izumo <iz@onicos.co.jp>
     * Version: 1.0
     * LastModified: Dec 25 1999
     * This library is free.  You can redistribute it and/or modify it.
     */

    var out, i, len, c;
    var char2, char3;

    out = "";
    len = str.length;
    i = 0;
    while (i < len) {
      c = str.charCodeAt(i++);
      switch (c >> 4) { 
        case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
          // 0xxxxxxx
          out += str.charAt(i - 1);
          break;
        case 12: case 13:
          // 110x xxxx   10xx xxxx
          char2 = str.charCodeAt(i++);
          out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
          break;
        case 14:
          // 1110 xxxx  10xx xxxx  10xx xxxx
          char2 = str.charCodeAt(i++);
          char3 = str.charCodeAt(i++);
          out += String.fromCharCode(((c & 0x0F) << 12) |
                 ((char2 & 0x3F) << 6) |
                 ((char3 & 0x3F) << 0));
          break;
      }
    }

    return out;
  }

}
%>