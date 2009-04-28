Tinyasp Framework 0.1 beta3

  A tiny framework for asp, implemented in JavaScript with basic MVC. And it provides
some useful functions or features.

Install on IIS
==============

1. Create a new website, or set the document root to the root path of the framework,
where you can find this file README.txt.

2. Add bin\IsapiRewrite4.dll to ISAPI filter.
Filter name: IsapiRewrite4
Executable: absolute path of bin\IsapiRewrite4.dll

3. Download and install components.
The full functions of the framework require below components:
JMail      Required by $.Mail, sending and receiving mails.
w3Socket   Required by $.Net.Socket, using sockets.
XYGrapics  Required by $.Image, creating and zooming images.
XZip       Required by $.Zip, compressing and decompressing zip files.

Download Dependencies.7z, unpack and run install.bat to install these components.
Restart of IIS may required, if components are not active.

Documentation
=============
View documentation online at http://tinyasp.org/docs/.
