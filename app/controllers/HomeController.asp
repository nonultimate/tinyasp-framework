<%
HomeController = $.Controller({

  index: function() {
    // Using view to display
    msg = "Hello from Tinyasp!";
    $.view.setTitle("Home");
    $.view.setLayout("default");
    $.view.display();
  }

});
%>