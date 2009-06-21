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
 * @package   Mail
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

if (!objectExists("JMail.Message")) {
  error("JMail not installed");
}
// Load mail configuration
if ($.File.isFile(APPPATH + "config\\mail.asp")) {
  eval(include(APPPATH + "config\\mail.asp"));
}

/**
 * Class Mail
 */
function Mail() {
  this.server = "";
  this.msg = Server.CreateObject("JMail.Message");
  if (defined(CONFIG["mail"])) {
    if (defined(CONFIG["mail"]["server"])) {
      this.server = CONFIG["mail"]["server"];
    }
    if (defined(CONFIG["mail"]["user"])) {
      this.msg.MailServerUserName = CONFIG["mail"]["user"];
    }
    if (defined(CONFIG["mail"]["password"])) {
      this.msg.MailServerPassWord = CONFIG["mail"]["password"];
    }
  }
  this.setCharset(CONFIG["charset"]);
}

Mail.prototype = {

  /**
   * Set the mail server
   * @param  host     the mail server
   * @param  user     [optional]the user to login to the server
   * @param  password [optional]the password to login to the server
   * @return void
   */
  setServer: function(host, user, password) {
    this.server = host;
    if (defined(password)) {
      this.msg.MailServerUserName = user;
      this.msg.MailServerPassWord = password;
      this.setFrom(user);
    }
  },

  /**
   * Set the charset
   * @param  charset  the encoding of the data
   * @return void
   */
  setCharset: function(charset) {
    this.msg.Charset = charset;
  },

  /**
   * Set the sender
   * @param  from  the sender of the mail
   * @param  name  the name of the sender
   * @return void
   */
  setFrom: function(from, name) {
    this.msg.From = from;
    if (defined(name)) {
      this.msg.FromName = name;
    }
  },

  /**
   * Set the reply address
   * @param  to  the reply address
   * @return void
   */
  setReply: function(to) {
    this.msg.ReplyTo = to;
  },

  /**
   * Add an attachment
   * @param  filename  the file to add
   * @param  inline    [optional]the file is inline or not
   * @return integer
   */
  addAttach: function(filename, inline) {
    if (!defined(inline)) {
      return this.msg.AddAttachment(filename);
    } else {
      return this.msg.AddAttachment(filename, inline);
    }
  },

  /**
   * Add an attachment in the web
   * @param  url     the attachment URL
   * @param  inline  [optional]the file is inline or not
   * @return integer
   */
  addURLAttach: function(url, inline) {
    if (!defined(inline)) {
      this.msg.AddURLAttachment(url, basename(url));
    } else {
      this.msg.AddURLAttachment(url, basename(url), inline);
    }
  },

  /**
   * Add a recipient
   * @param  to    the mail address of the recipient
   * @param  name  the name of the recipient
   * @return void
   */
  addRe: function(to, name) {
    if (defined(name)) {
      this.msg.AddRecipient(to, name);
    } else {
      this.msg.AddRecipient(to);
    }
  },

  /**
   * Add a carbon copy recipient
   * @param  to  the mail address of the recipient
   * @return void
   */
  addReCC: function(to) {
    this.msg.AddRecipientCC(to);
  },

  /**
   * Add a blind carbon copy recipient
   * @param  to  the mail address of the recipient
   * @return void
   */
  addReBCC: function(to) {
    this.msg.AddRecipientBCC(to);
  },

  /**
   * Send the mail
   * @param  subject the subject of the mail
   * @param  body    the content of the mail
   * @param  isHTML  [optional]plain text or HTML
   * @return boolean
   */
  send: function(subject, body, isHTML) {
    if (arguments.length == 4) {
      return this.mail(arguments[0], arguments[1], arguments[2], arguments[3]);
    } else if(arguments.length == 5) {
      return this.mail(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
    }
    if (!defined(isHTML)) {
      isHTML = false;
    }
    this.msg.Subject = subject;
    if (isHTML) {
      this.msg.HTMLBody = body;
    } else {
      this.msg.Body = body;
    }
    return this.msg.Send(this.server);
  },

  /**
   * Send a single mail
   * @param  from    the mail sender
   * @param  to      the one you send to
   * @param  subject the subject of the mail
   * @param  body    the content of the mail
   * @param  isHTML  [optional]plain text or HTML
   * @return boolean
   */
  mail: function(from, to, subject, body, isHTML) {
    if (!defined(isHTML)) {
      isHTML = false;
    }
    var s = from.indexOf("<");
    if (s == -1) {
      this.msg.From = from.trim();
    } else {
      this.msg.FromName = from.substring(0, s).trim();
      this.msg.From = from.substring(s, from.indexOf(">")).trim();
    }
    var a = to.split(",");
    var len = a.length;
    for (var i = 0; i < len; i++) {
      s = a[i].indexOf("<");
      if (s == -1) {
        this.msg.AddRecipient(a[i].trim());
      } else {
        this.msg.AddRecipient(a[i].substring(0, s).trim(), a[i].substring(s, a[i].indexOf(">")).trim());
      }
    }
    this.msg.Subject = subject;
    if (isHTML) {
      this.msg.HTMLBody = body;
    } else {
      this.msg.Body = body;
    }
    return this.msg.Send(this.server);
  }

}

$.Mail = new Mail();
%>