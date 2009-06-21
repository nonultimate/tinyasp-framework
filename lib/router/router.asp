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
 * @package   Router
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

eval(include(APPLIB + "file\\file.asp"));

/**
 * Class Router
 */
function Router(controller, action, param) {
  /**
   * The controller name
   */
  $.controller = controller || "";
  /**
   * The action name
   */
  $.action = action || "index";
  /**
   * The parameter variables
   */
  $.param = param || new Array();
  /**
   * The cache file of the view
   */
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
        var str = TServer("QUERY_STRING").replace(/^q=[^&]*/i, "");
        if (CONFIG["cache_view"] && $.isGet && str == "") {
          cache = true;
          var url = $.controller + "/" + $.action;
          if ($.param.length > 0) {
            url += "/" + $.param.join("/");
          }
          $.cache_file = APPPATH + "cache\\" + encodeURIComponent(url);
          var cache_mdtime = $.File.isFile($.cache_file) ? $.File.modified($.cache_file) : 0;
          var controller_mdtime = $.File.modified(APPPATH + "controllers\\" + ucfirst($.controller) + "Controller.asp");
          var view_file = APPPATH + "views\\html\\" + $.controller + "\\" + $.action + "." + CONFIG["template_extension"];
          var view_mdtime = $.File.isFile(view_file) ? $.File.modified(view_file) : cache_mdtime;
          var tmp_file = APPPATH + "tmp\\" + $.controller + "_" + $.action;
          if (cache_mdtime < controller_mdtime || cache_mdtime < view_mdtime) {
            cache = false;
          }
          if ($.File.isFile(tmp_file)) {
            eval("var obj = " + $.File.readFile(tmp_file) + ";");
            if (defined(obj.layout)) {
              var layout_file = APPPATH + "views\\layout\\" + obj.layout + "." + CONFIG["template_extension"];
              if ($.File.isFile(layout_file) && cache_mdtime < $.File.modified(layout_file)) {
                cache = false;
              }
            }
            if (cache == true && defined(obj.models)) {
              var len = obj.models.length;
              var model_path;
              for (var i = 0; i < len; i++) {
                model_path = APPPATH + "models\\" + obj.models[i] + ".asp";
                if ($.File.isFile(model_path) && cache_mdtime < $.File.modified(model_path)) {
                  cache = false;
                  break;
                }
              }
            }
            if (cache == true && defined(obj.tables)) {
              var len = obj.tables.length;
              var table_path;
              for (var i = 0; i < len; i++) {
                table_path = APPPATH + "data\\modified\\" + obj.tables[i];
                if ($.File.isFile(table_path) && cache_mdtime < $.File.modified(table_path)) {
                  cache = false;
                  break;
                }
              }
            }
          }
        }
        if (cache) {
          $.File.output($.cache_file);
        } else {
          // Initialize form variables
          $.init();
          // Include libraries
          eval(include(APPLIB + "controller\\controller.asp")); 
          eval(include(APPLIB + "cookie\\cookie.asp"));
          eval(include(APPLIB + "session\\session.asp"));
          eval(include(path));
          try {
            var action = eval(controllerName + "." + $.action);
            if (!defined(action)) {
              redirect(404);
            }
            var m = action.toString().match(/new\s+([A-Za-z0-9_]+)Model/g);
            if (m) {
              eval(include(APPLIB + "model\\model.asp"));
              var model = "";
              var len = m.length;
              for (var i = 0; i < len; i++) {
                model = m[i].replace(/new\s+/, "");
                if (!find(MODELS, model)) {
                  MODELS.push(model);
                }
                eval(include(APPPATH + "models\\" + model + ".asp"));
              }
            }
            action();
          } catch(e) {
            error("An error occured in " + controllerName + "." + $.action + "()", e);
          }
          // Remove uploaded files
          if ($.files.length > 0) {
            for (var item in $.files) {
              $.File.remove($.files[item]["path"]);
            }
          }
        }
      } catch(e) {
        error("An error occured in controller " + controllerName, e);
      }
    } else {
      error("No Index controller");
    }
  }

}

$.Router = function(controller, action, param) {
  return new Router(controller, action, param);
}
%>