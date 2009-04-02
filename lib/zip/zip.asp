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
 * @package   Zip
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

if (!objectExists("XStandard.Zip")) {
  die("XZip not installed");
}

$.Zip = {

  /**
   * The instance of XZip object
   */
  zip: Server.CreateObject("XStandard.Zip"),

  /**
   * Create a zip archive
   * @param  path    the path of the file or folder
   * @param  archive [optional]the archive name to save
   * @return void
   */
  pack: function(path, archive) {
    var src = realpath(path);
    var dest = defined(archive) ? realpath(archive) : src + ".zip";
    this.zip.Pack(src, dest);
  },

  /**
   * Extract a zip archive
   * @param  archive the archive to extract
   * @param  path    [optional]the path to extract to
   * @return void
   */
  unpack: function(archive, path) {
    var src = realpath(archive);
    var dest = defined(path) ? realpath(path) : realpath(".");
    this.zip.Unpack(src, dest);
  }

}
%>