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
 * @package   File
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

//---- Binary or text type
var adTypeBinary = 1;
var adTypeText = 2;

//---- File options
var adForReading = 1;
var adForWriting = 2;
var adForAppending = 8;
var adSaveCreateNotExist = 1;
var adSaveCreateOverWrite = 2;

$.File = {

  /**
   * File Object
   */
  fso: Server.CreateObject("Scripting.FileSystemObject"),

  /**
   * Ensure file exists
   * @param path the path of the file or folder
   * @return boolean
   */
  exists: function(path) {
    var p = realpath(path);
    if (this.fso.FileExists(p) || this.fso.FolderExists(p)) {
      return true;
    } else {
      return false;
    }
  },

  /**
   * Ensure path is a file
   * @param  path  the path of the file
   * @return boolean
   */
  isFile: function(path) {
    if (this.fso.FileExists(realpath(path))) {
      return true;
    } else {
      return false;
    }
  },

  /**
   * Ensure path is a directory
   * @param  path  the path of the folder
   * @return boolean
   */
  isDir: function(path) {
    if (this.fso.FolderExists(realpath(path))) {
      return true;
    } else {
      return false;
    }
  },

  /**
   * Create a folder
   * @param  path  the path of the folder
   * @return boolean
   */
  mkdir: function(path) {
    if (this.exists(path)) {
      return false;
    }
    try {
      this.fso.CreateFolder(realpath(path));
      return true;
    } catch (e) {
      return false;
    }
  },

  /**
   * Remove a folder
   * @param  path  the path of the folder
   * @return boolean
   */
  rmdir: function(path) {
    if (!this.isDir(path)) {
      return false;
    }
    try {
      this.fso.DeleteFolder(realpath(path), true);
      return true;
    } catch (e) {
      return false;
    }
  },

  /**
   * Remove a file
   * @param  path  the path of the file
   * @return boolean
   */
  remove: function(path) {
    if (!this.isFile(path)) {
      return false;
    }
    try {
      this.fso.DeleteFile(realpath(path), true);
      return true;
    } catch (e) {
      return false;
    }
  },

  /**
   * Copy file or folder to destination path
   * @param  src  the source file or folder
   * @param  dest the destination path to copy to
   * @return boolean
   */
  copy: function(src, dest) {
    var s = realpath(src);
    var d = realpath(dest);
    if (!this.exists(s)) {
      return false;
    }
    try {
      if (this.isFile(s)) {
        this.fso.CopyFile(s, d, true);
      } else {
        this.fso.CopyFolder(s, d, true);
      }
      return true;
    } catch (e) {
      return false;
    }
  },

  /**
   * Get the size of the file or folder
   * @param  path  the path of the file or folder
   * @return integer
   */
  size: function(path) {
    var f = this.isFile(path) ? this.fso.GetFile(realpath(path)) : this.fso.GetFolder(realpath(path));

    return f.Size;
  },

  /**
   * Get the created time of the file or folder
   * @param  path  the path of the file or folder
   * @return string
   */
  created: function(path) {
    var f = this.isFile(path) ? this.fso.GetFile(realpath(path)) : this.fso.GetFolder(realpath(path));

    return f.DateCreated;
  },

  /**
   * Get the last accessed time of the file or folder
   * @param  path  the path of the file or folder
   * @return string
   */
  accessed: function(path) {
    var f = this.isFile(path) ? this.fso.GetFile(realpath(path)) : this.fso.GetFolder(realpath(path));

    return f.DateLastAccessed;
  },

  /**
   * Get the last modified time of the file or folder
   * @param  path  the path of the file or folder
   * @return string
   */
  modified: function(path) {
    var f = this.isFile(path) ? this.fso.GetFile(realpath(path)) : this.fso.GetFolder(realpath(path));

    return f.DateLastModified;
  },

  /**
   * Update the last modified time of the file, it will be created if not exists
   * @param  filename  the file to touch
   * @return void
   */
  touch: function(filename) {
    var stream = $.File.TextStream();
    stream.open(filename, "r+");
    stream.close();
  },

  /**
   * Get the drive name of the path
   * @param  path  the path of the file or folder
   * @return string
   */
  drive: function(path) {
    return this.fso.GetDriveName(path);
  },

  /**
   * Get the file extension name
   * @param  path  the path of the file
   * @return string
   */
  extension: function(path) {
    return this.fso.GetExtensionName(realpath(path));
  },

  /**
   * Get the file, folder or drive object
   * @param  path  the path of the file or folder
   * @return object
   */
  get: function(path) {
    if (/^[a-z]:\\?$/i.test(path)) {
      var d = this.fso.GetDrive(path);
      return d;
    } else {
      var f = this.isFile(path) ? this.fso.GetFile(realpath(path)) : this.fso.GetFolder(realpath(path));
      return f;
    }
  },

  /**
   * Get files in the folder
   * @param  path  the path of the folder
   * @return enumerator
   */
  getFiles: function(path) {
    var f = this.fso.GetFolder(realpath(path));

    return new Enumerator(f.Files);
  },

  /**
   * Get the folders in the folder
   * @param  path  the path of the folder
   * @return enumerator
   */
  getFolders: function(path) {
    var f = this.fso.GetFolder(realpath(path));

    return new Enumerator(f.SubFolders);
  },

  /**
   * Get drives of the local machine
   * @return enumerator
   */
  getDrives: function() {
    return new Enumerator(this.fso.Drives);
  },

  /**
   * Read all data from the file and output
   * @param  path    the file path
   * @param  charset [optional]the encoding of the file
   * @return void
   */
  output: function(path, charset) {
    var stream = $.File.TextStream(adTypeText, charset);
    stream.open(realpath(path), "r");
    var size = stream.size();
    var i = 0;
    while (i < size) {
      echo(stream.read(1024));
      i += 1024;
    }
    stream.close();
  },

  /**
   * Read all data from the file
   * @param  path    the file path
   * @param  charset [optional]the encoding of the file
   * @return string
   */
  readFile: function(path, charset) {
    var stream = Server.CreateObject("ADODB.Stream");
    stream.Type = adTypeText;
    stream.Charset = defined(charset) ? charset : CONFIG["charset"];
    stream.Open();
    stream.LoadFromFile(realpath(path));
    var data = stream.ReadText();
    stream.Close();
    return data;
  },

  /**
   * Write data to the file
   * @param  path    the file path
   * @param  data    the data to write
   * @param  charset [optional]the encoding of the data
   * @return boolean
   */
  writeFile: function(path, data, charset) {
    try {
      var stream = Server.CreateObject("ADODB.Stream");
      stream.Type = adTypeText;
      stream.Charset = defined(charset) ? charset : CONFIG["charset"];
      stream.Open();
      stream.WriteText(data);
      stream.SaveToFile(realpath(path), adSaveCreateOverWrite);
      stream.Flush();
      stream.Close();
      return true;
    } catch (e) {
      return false;
    }
  }

}

/**
 * Class TextStream
 * @param  type    [optional]binary or text, adTypeBinary, adTypeText.
 *                 Default is adTypeText.
 * @param  charset [optional]the encoding of the data
 */
function TextStream(type, charset) {
  this.stream = Server.CreateObject("ADODB.Stream");
  this.mode = "r";
  if (!defined(type)) {
    type = adTypeText;
  }
  this.stream.Type = type;
  if (type == adTypeText) {
    this.stream.Charset = defined(charset) ? charset : CONFIG["charset"];
  }
}

TextStream.prototype = {

  /**
   * Open a file for reading or writing
   * @param  path  the file path
   * @param  mode  [optional]the mode for reading or writing,
   *               "r", "w", "w+", "rw", "rw+". Default is read only.
   * @return boolean
   */
  open: function(path, mode) {
    if (defined(mode)) {
      this.mode = mode.toLowerCase();
    }
    try {
      this.file = realpath(path);
      this.stream.Open();
      if (this.mode.match(/[r\+]/) && $.File.isFile(this.file)) {
        this.stream.LoadFromFile(this.file);
      }
      if (this.mode == "r") {
        this.stream.Mode = adModeRead;
      } else if(this.mode.match(/^w/)) {
        this.stream.Mode = adModeWrite;
      } else if(this.mode.match(/^rw/)) {
        this.stream.Mode = adModeReadWrite;
      }
      if (this.mode.indexOf("+") > -1) {
        this.seek(this.size());
      }
      return true;
    } catch (e) {
      return false;
    }
  },

  /**
   * Close the stream
   * @return void
   */
  close: function() {
    if (this.mode.match(/[w\+]/)) {
      this.stream.SaveToFile(this.file, adSaveCreateOverWrite);
    }
    this.stream.Close();
  },

  /**
   * Read size of data from the stream
   * @param  len  The length of data to read
   * @return string
   */
  read: function(len) {
    if (this.stream.Type == adTypeBinary) {
      return this.stream.Read(len);
    } else {
      return this.stream.ReadText(len);
    }
  },

  /**
   * Write data to the stream
   * @param  data  the data to write to the stream
   * @return void
   */
  write: function(data) {
    if (this.stream.Type == adTypeBinary) {
      this.stream.Write(data);
    } else {
      this.stream.WriteText(data);
    }
    this.stream.Flush();
  },

  /**
   * Ensures the stream is end
   * @return boolean
   */
  eof: function() {
    return this.stream.EOS;
  },

  /**
   * Set the current cursor of the stream
   * @param  pos  the position of the stream to set
   * @return void
   */
  seek: function(pos) {
    this.stream.Position = pos;
  },

  /**
   * Get the current cursor position of the stream
   * @return integer
   */
  tell: function() {
    return this.stream.Position;
  },

  /**
   * Get the size of the stream
   * @return Integer
   */
  size: function() {
    return this.stream.Size;
  }

}

$.File.TextStream = function(type, charset) {
  return new TextStream(type, charset);
}
%>