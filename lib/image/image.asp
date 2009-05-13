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
 * @package   Image
 * @author    Joe D. <nonultimate@gmail.com>
 * @copyright Copyright (c) 2008 - 2009, Joe Dotoff
 * @license   New BSD License, see LICENSE.txt
 */

if (!objectExists("XY.Graphics")) {
  error("XYGraphics not installed");
}

eval(include(APPLIB + "image\\xygraphics.asp"));

$.Image = {

  /**
   * The instance of XYGraphics object
   */
  image: Server.CreateObject("XY.Graphics"),

  /**
   * The height of the image
   */
  height: 0,

  /**
   * The width of the image
   */
  width: 0,

  /**
   * Create validation code image
   * @param  code   the validation code string
   * @param  width  the width of the image
   * @param  height the height of the image
   * @return void
   */
  createCode: function(code, width, height) {
    var len = code.length;
    if (!defined(width)) {
      width = 10;
      for (var i = 0; i < len; i++) {
        if (code.charCodeAt(i) > 255) {
          width += 30;
        } else {
          width += 20;
        }
      }
    }
    if (!defined(height)) {
      height = 30;
    }
    this.create(width, height, xyWhite, true);
    var x = 5, y = 0, r = 0, n;
    var colors = [xyBlack, xyBlue, xyOrange, xyGreen, xyPurple];
    var size = colors.length;
    // Draw miscellaneous points
    for (var i = 0; i < width; i++) {
      i += Math.round(Math.random() * 15);
      for (var j = 0; j < height; j++) {
        j += Math.round(Math.random() * 15);
        n = Math.floor(Math.random() * size);
        this.setPen(colors[n]);
        this.drawLine(i, j, i + 1, j + 1);
      }
    }
    // Draw text string
    for (var i = 0; i < len; i++) {
      r = Math.round(Math.random() * 10);
      n = Math.floor(Math.random() * size);
      this.setFont("monospace", 20, 0, colors[n], xyWhite);
      this.drawText(code.charAt(i), x, y, 100, r);
      if (code.charCodeAt(i) > 255) {
        x += 30;
      } else {
        x += 20;
      }
    }
    // Output image
    this.output();
    this.close();
  },

  /**
   * Cut out the image
   * @param  left    the left offset
   * @param  top     the top offset
   * @param  right   the right offset
   * @param  bottom  the bottom offset
   * @return void
   */
  cut: function(left, top, right, bottom) {
    this.image.Clipping(left, top, right, bottom);
  },

  /**
   * Create an image
   * @param  width       the width of the image
   * @param  height      the height of the image
   * @param  bgcolor     [optional]the background color
   * @param  transparent [optional]whether the image is transparent
   * @param  transcolor  [optional]the transparent color of the image
   * @return void
   */
  create: function(width, height, bgcolor, transparent, transcolor) {
    if (!defined(bgcolor)) {
      bgcolor = xyWhite;
    }
    this.width = width;
    this.height = height;
    this.image.New(width, height, bgcolor);
    if (defined(transparent)) {
      this.image.IsTrans = transparent;
    }
    if (defined(transcolor)) {
      this.image.TransColor = transcolor;
    }
  },

  /**
   * Open an image
   * @param  path  the path of the image
   * @return void
   */
  open: function(path) {
    this.image.Open(realpath(path));
    this.height = this.image.Height;
    this.width = this.image.Width;
  },

  /**
   * Close the image
   * @return void
   */
  close: function() {
    this.image.Close();
  },

  /**
   * Save the image
   * @param  filename  [optional]the image filename
   * @return void
   */
  save: function(filename) {
    if (defined(filename)) {
      this.image.SaveAs(realpath(filename));
    } else {
      this.image.Save();
    }
  },

  /**
   * Resize the size of the image
   * @param  width   the width to resize to
   * @param  height  the height to resize to
   * @return void
   */
  resize: function(width, height) {
    this.image.Resize(width, height);
  },

  /**
   * Zoom the image
   * @param  width   the width to zoom to
   * @param  height  the height to zoom to
   * @return void
   */
  zoom: function(width, height) {
    var ratio = width / this.width;
    var ratio2 = height / this.height;
    if (width == 0 || ratio > ratio2) {
      ratio = ratio2;
    }
    this.image.Zoom(ratio);
  },

  /**
   * Output the image to the browser
   * @param  type  [optional]the image type, default is xyJPG
   * @return void
   */
  output: function(type) {
    if (!defined(type)) {
      type = xyJPG;
    }
    this.image.ImageOut(type);
  },

  /**
   * Set the brush style
   * @param  color  the color of the brush
   * @param  style  [optional]the style of the brush
   * @return void
   */
  setBrush: function(color, style) {
    if (!defined(style)) {
      style = xyBrushSolid;
    }
    this.image.SetBrush(color, style);
  },

  /**
   * Set the font style
   * @param  font     the font name
   * @param  size     the size of the font
   * @param  style    [optional]the text style
   * @param  color    [optional]the text color
   * @param  bgcolor  [optional]the background color
   */
  setFont: function(font, size, style, color, bgcolor) {
    if (!defined(bgcolor)) {
      bgcolor = xyWhite;
    }
    if (!defined(color)) {
      color = xyBlack;
    }
    if (!defined(style)) {
      style = 0;
    }
    this.image.SetFont(font, size, style, color, bgcolor);
  },

  /**
   * Set the pen style
   * @param  color  the color of the pen
   * @param  size   [optional]the size of the pen
   * @param  style  [optional]the style of the pen
   */
  setPen: function(color, size, style) {
    if (!defined(size)) {
      size = 1;
    }
    if (!defined(style)) {
      style = xyPenSolid;
    }
    this.image.SetPen(color, size, style);
  },

  /**
   * Draw circle
   * @param  x  the center X offset
   * @param  y  the center Y offset
   * @param  r  the radius of the circle
   * @return void
   */
  drawCircle: function(x, y, r) {
    this.image.Circle(x, y, r);
  },

  /**
   * Draw ellipse
   * @param  cx      the center X offset
   * @param  cy      the center Y offset
   * @param  width   the long radius
   * @param  height  the short radius
   * @return void
   */
  drawEllipse: function(cx, cy, width, height) {
    this.image.Arc(cx - width, cy - height, cx + width, cy + height, cx - width, cy, cx - width, cy);
  },

  /**
   * Draw line
   * @param  x1  the X offset of the start point
   * @param  y1  the Y offset of the start point
   * @param  x2  the X offset of the end point
   * @param  y2  the Y offset of the end point
   * @return void
   */
  drawLine: function(x1, y1, x2, y2) {
    this.image.Line(x1, y1, x2, y2);
  },

  /**
   * Draw rectangle
   * @param  left    the left offset
   * @param  top     the top offset
   * @param  right   the right offset
   * @param  bottom  the bottom offset
   * @return void
   */
  drawRectangle: function(left, top, right, bottom) {
    this.image.Rectangle(left, top, right, bottom);
  },

  /**
   * draw text
   * @param  text   the text to draw
   * @param  x      the left offset
   * @param  y      the top offset
   * @param  alpha  [optional]alpha of the text
   * @param  angle  [optional]the angle to rotate the text
   */
  drawText: function(text, x, y, alpha, angle) {
    if (!defined(angle)) {
      angle = 0;
    }
    if (!defined(alpha)) {
      alpha = 50;
    }
    this.image.setText(x, y, alpha, angle, text);
  }

};
%>