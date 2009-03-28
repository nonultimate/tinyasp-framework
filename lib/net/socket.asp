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
 * @package   Net
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 * @version   $Id: socket.asp 60 2009-03-05 02:48:45Z joe $
 */

if (!objectExists("Socket.TCP")) {
  die("w3Socket not installed");
}

eval(include(APPLIB + "net\\net.asp"));

$.Net.Socket = {

  /**
   * Socket object
   */
  sock: Server.CreateObject("Socket.TCP"),

  /**
   * Close the socket
   * @return void
   */
  close: function() {
    this.sock.Close();
  },

  /**
   * Open the socket
   * @param  host    the host to open
   * @param  port    the port to open
   * @param  timeout [optional]seconds of timeout
   * @return void
   */
  open: function(host, port, timeout) {
    this.sock.Host = host + ":" + port;
    if (defined(timeout)) {
      this.sock.TimeOut = timeout;
    }
    this.sock.Open();
  },

  /**
   * Get the buffer string
   * @return string
   */
  getBuffer: function() {
    return this.sock.Buffer;
  },

  /**
   * Read size of data from the socket
   * @param  len  the length to read
   * @return string
   */
  read: function(len) {
    return this.sock.GetText(len);
  },

  /**
   * Read a line of data from the socket
   * @return string
   */
  readLine: function() {
    return this.sock.GetLine();
  },

  /**
   * Read all the data from the socket
   * @return string
   */
  readAll: function() {
    this.sock.WaitForDisconnect();

    return this.sock.Buffer;
  },

  /**
   * Wait for receiving data
   * @return void
   */
  wait: function() {
    this.sock.Wait();
  },

  /**
   * Send data to the socket
   * @param  text  the data to send
   * @return void
   */
  write: function(text) {
    this.sock.SendText(text);
  },

  /**
   * Send data with a line end character to the socket
   * @param  text  the data to send
   * @return void
   */
  writeLine: function(text) {
    this.sock.SendLine(text);
  }

};
%>