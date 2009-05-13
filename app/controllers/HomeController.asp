<%
HomeController = $.Controller({

  index: function() {
    // Using view to display
    $.view.assign("msg", "Hello from Tinyasp!");
    $.view.setTitle("Home");
    $.view.setLayout("default");
    $.view.display();
  }

});
%>