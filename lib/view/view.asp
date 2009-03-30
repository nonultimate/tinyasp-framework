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
 * @package   View
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "template\\template.asp"));

$.View = function(file) {
  return new View(file);
}

/**
 * Class View
 * @param  file  the template file
 */
function View(file) {
  if (!defined(file)) {
    file = APPPATH + "views\\html\\" + $.controller + "\\" + $.action + "." + CONFIG["template_extension"];
  }
  this.title = ucfirst($.action);
  this.layout = false;
  this.component = false;
  var tpl = $.Template();

  /**
   * Add a variable for replacement
   * @param  name  the variable name
   * @param  value the variable value
   * @return void
   */
  this.assign = function(name, value) {
    tpl.assign(name, value);
  };

  /**
   * Display the view
   * @return void
   */
  this.display = function() {
    if(!$.File.isFile(file)) {
      die("The view template " + file + " not found");
    }
    if (this.component) {
      // Use component to render the view
      eval(include(APPLIB + "view\\component.asp"));
      if (this.layout != false) {
        tpl.add(this.Component.getContent(file, this.layout));
        $.File.writeFile(APPPATH + "tmp\\" + $.controller + "_" + $.action, this.layout);
      } else {
        tpl.add(this.Component.getContent(file));
      }
    } else {
      // Simple template engine
      tpl.addFile(file);
    }
    if (this.layout == false) {
      $.File.remove(APPPATH + "tmp\\" + $.controller + "_" + $.action);
    }
    if (CONFIG["cache_view"] && $.isGet) {
      tpl.setCache($.cache_file);
    }
    tpl.display();
  };

  /**
   * Set the layout for the view
   * @param  layout  the layout to display the view
   * @return void
   */
  this.setLayout = function(layout) {
    this.layout = layout;
    this.component = true;
  };

  /**
   * Set the title for the view
   * @param  title  the title for the view
   * @return void
   */
  this.setTitle = function(title) {
    this.title = title;
  };
}
%>