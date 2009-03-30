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
 * @package   Router
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "file\\file.asp"));
eval(include(APPLIB + "text\\text.asp"));

/**
 * Class Router
 */
function Router(controller, action, param) {
  $.controller = controller ? controller : "";
  $.action = action ? action : "index";
  $.param = param ? param : new Array();
  $.url = "";
  $.cache_file = "";
  this.dispatch();
}

Router.prototype = {

  /**
   * Dispatch the controller
   * @return void
   */
  dispatch: function() {
    if ($.controller == "") {
      if ($.File.exists(APPPATH + "controllers\\IndexController.asp")) {
        $.controller = "index";
      } else if($.File.exists(APPPATH + "controllers\\HomeController.asp")) {
        $.controller = "home";
      }
    }
    if ($.controller != "") {
      var controllerName = ucfirst($.controller) + "Controller";
      var path = APPPATH + "controllers\\" + controllerName + ".asp";
      if (!$.File.exists(path)) {
        redirect(404);
      }
      try {
        var cache = false;
        var str = $.server["QUERY_STRING"].replace(/^q=[^&]*/i, "");
        if (CONFIG["cache_view"] && $.isGet && str == "") {
          var url = $.controller + "/" + $.action;
          if ($.param.length > 0) {
            url += "/" + $.param.join("/");
          }
          $.cache_file = APPPATH + "cache\\" + $.Text.crc32(url);
          var cache_mdtime = $.File.isFile($.cache_file) ? $.File.modified($.cache_file) : 0;
          var controller_mdtime = $.File.modified(APPPATH + "controllers\\" + ucfirst($.controller) + "Controller.asp");
          var view_file = APPPATH + "views\\html\\" + $.controller + "\\" + $.action + "." + CONFIG["template_extension"];
          var view_mdtime = $.File.isFile(view_file) ? $.File.modified(view_file) : cache_mdtime;
          var layout_file = APPPATH + "tmp\\" + $.controller + "_" + $.action;
          var layout_mdtime = 0;
          if ($.File.isFile(layout_file)) {
            layout_file = APPPATH + "views\\layout\\" + $.File.readFile(layout_file) + "." + CONFIG["template_extension"];
            if (!$.File.isFile(layout_file)) {
              die("The layout " + layout_file + " not found");
            }
            layout_mdtime = $.File.modified(layout_file);
          }
          if (cache_mdtime > controller_mdtime && cache_mdtime > view_mdtime && cache_mdtime > layout_mdtime) {
            cache = true;
            $.File.output($.cache_file);
          }
        }
        if (cache == false) {
          // Include libraries
          eval(include(APPLIB + "controller\\controller.asp")); 
          eval(include(APPLIB + "cookie\\cookie.asp"));
          eval(include(APPLIB + "session\\session.asp"));
          eval(include(path));
          try {
            eval(controllerName + "." + $.action + "()");
          } catch(e) {
            die("An error occured in " + controllerName + "." + $.action + "()");
          }
          // Remove uploaded files
          if ($.files.length > 0) {
            for (item in $.files) {
              $.File.remove($.files[item]["path"]);
            }
          }
        }
      } catch(e) {
        die("An error occured in controller " + controllerName);
      }
    } else {
      die("No Index controller");
    }
  }

}

$.Router = function(controller, action, param) {
  return new Router(controller, action, param);
}
%>