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

// Font style
var xyBold = 8;
var xyItalic = 4;
var xyUnderline = 2;
var xyStrikeOut = 1;

// Boolean type
var xyTrue = 1;
var xyFlase = 0;

// Pen style
var xyPenSolid = 0;
var xyPenDash = 1;
var xyPenDot = 2;
var xyPenDashDot = 3;
var xyPenDashDotDot = 4;
var xyPenClear = 5;
var xyPenInsideFrame = 6;

// Brush style
var xyBrushSolid = 0;
var xyBrushCross = 1;
var xyBrushDiagCross = 2;
var xyBrushClear = 3;
var xyBrushBDiagonal = 4;
var xyBrushFDiagonal = 5;
var xyBrushHorizontal = 6;
var xyBrushVertical = 7;

// File type
var xyBMP = 0;
var xyJPG = 1;
var xyGIF = 2;
var xyPNG = 3;

// Color
var xyRed = 0x0000FF;
var xyBlue = 0xFF0000;
var xyYellow = 0xFFFF00;
var xyGreen = 0x00FF00;
var xyBlack = 0x000000;
var xyWhite = 0xFFFFFF;
var xyGray = 0x999999;
var xyPurple = 0xFF00FF;
var xyOrange = 0x0099FF;

// Pixel format
var xypfDevice = 0;
var xypf1bit = 1;
var xypf4bit = 4;
var xypf8bit = 8;
var xypf15bit = 15;
var xypf16bit = 16;
var xypf24bit = 24;
var xypf32bit = 32;
var xypfCustom = -1;
%>