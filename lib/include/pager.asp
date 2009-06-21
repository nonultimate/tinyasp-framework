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
 * @package   Include
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

/**
 * Pager class
 * @param  total  the total number of records
 * @param  size   the size of records to display per page
 * @param  query  the query string for the current page or records offset
 */
Pager = function(total, size, query) {
  this.current = 1;
  this.type = 1;
  this.total = total;
  this.offset = 0;
  this.size = size;
  this.page = Math.ceil(total / size);
  if ($.param.length > 1 && $.param[$.param.length - 2] == query && isNumeric($.param[$.param.length - 1])) {
    var page = $.param[$.param.length - 1];
    if (page >= 1 && page <= this.page) {
      this.current = page;
      this.offset = (page - 1) * this.size;
    } else {
      if ($.cache_file != "") {
        $.File.remove($.cache_file);
      }
      redirect(404);
    }
  } else if(!empty($.get[query]) && isNumeric($.get[query])) {
    var page = $.get[query];
    if (page >= 1 && page <= this.page) {
      this.current = page;
    } else if(page > this.page) {
      this.current = this.page;
    }
    this.offset = (this.current - 1) * this.size;
  }

  var linkStr1 = "/" + $.controller + "/" + $.action;
  var linkStr2 = "/" + $.query + "?";
  var str = $.server["QUERY_STRING"].replace(/^q=[^&]*&?/, "");
  str = str.replace(/&$/, "");
  for (var i in $.param) {
    if ($.param[i] == query) {
      break;
    }
    linkStr1 += "/" + $.param[i];
  }
  linkStr1 += "/" + query + "/{N}";
  if (str != "") {
    linkStr1 += "?" + str;
    if (defined($.get[query])) {
      linkStr2 += str.replace(query + "=" + $.get[query], query + "={N}");
    } else {
      linkStr2 += str + "&amp;" + query + "={N}";
    }
  } else {
    linkStr2 += query + "={N}";
  }

  /**
   * Get the link string
   * @param  type  the link string type, 1 or 2, default is 1.
   *         1 means the link string "/page/1"
   *         2 means the link string "?page=1"
   * @return string
   */
  this.getLinkStr = function(type) {
    if (!defined(type)) {
      type = this.type;
    }
    return (type == 1) ? linkStr1 : linkStr2;
  };

  /**
   * Set the link stirng type
   * @param  type  the link string type, 1 or 2.
   * @return void
   */
  this.setLinkType = function(type) {
    this.type = type;
  };

  /**
   * Set the current page
   * @param  p  the current page number
   * @return void
   */
  this.setPage = function(p) {
    if (p >= 1 && p <= this.page) {
      this.current = p;
      this.offset = (p - 1) * this.size;
    }
  };

  /**
   * Ensure the page has a previous page
   * @return boolean
   */
  this.hasPrev = function() {
    return this.current > 1;
  };

  /**
   * Ensure the page has a next page
   * @return boolean
   */
  this.hasNext = function() {
    return this.current < this.page;
  };

  /**
   * Ensure the page is the first page
   * @return boolean
   */
  this.isFirst = function() {
    return this.current == 1;
  };

  /**
   * Ensure the page is the last page
   * @return boolean
   */
  this.isLast = function() {
    return this.current == this.page;
  };

  /**
   * Get the first link
   * @param  type  the link string type, 1 or 2, default is 1.
   * @return string
   */
  this.firstLink = function(type) {
    return this.getLinkStr(type).replace(/\{N\}/, 1);
  };

  /**
   * Get the last link
   * @param  type  the link string type, 1 or 2, default is 1.
   * @return string
   */
  this.lastLink = function(type) {
    return this.getLinkStr(type).replace(/\{N\}/, this.page);
  };

  /**
   * Get the previous link
   * @param  type  the link string type, 1 or 2, default is 1.
   * @return string
   */
  this.prevLink = function(type) {
    if (this.hasPrev()) {
      return this.getLinkStr(type).replace(/\{N\}/, this.current - 1);
    } else {
      return "";
    }
  };

  /**
   * Get the next link
   * @param  type  the link string type, 1 or 2, default is 1.
   * @return string
   */
  this.nextLink = function(type) {
    if (this.hasNext()) {
      return this.getLinkStr(type).replace(/\{N\}/, this.current + 1);
    } else {
      return "";
    }
  };
}
%>