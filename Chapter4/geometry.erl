-module(geometry).
-export([area/1, perimeter/1]).

area({rectangle, Width, Height}) -> Width * Height;
area({square, Side})			 -> Side * Side;
area({triangle, Width, Height})  -> (Width * Height) / 2;
area({circle, Radius})			 -> 3.141569 * Radius * Radius.

perimeter({rectangle, Width, Height}) -> (Width*2) + (Height*2);
perimeter({square, Side}) 			  -> Side * 4;
perimeter({circle, Radius})           -> 2 * 3.141569 * Radius.
