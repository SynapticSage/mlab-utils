function asciiplot(x, y)
%ASCIIPLOT Plot Y as a function of X
%
%   PLOT(X,Y) produces a plot of  the  elements  of  Y  against
%   those  of X . PLOT(Y) is the same as PLOT(1:n,Y) where n is
%   the  number  of   elements   in   Y   .    PLOT(X,Y,P)   or
%   PLOT(X,Y,p1,...,pk)  passes the optional parameter vector P
%   or scalars p1 through pk to the plot routine.  The  default
%   plot  routine  is a crude printer-plot. It is hoped that an
%   interface to local graphics equipment can be provided.
%   An interesting example is
%       t = 0:50;
%       PLOT( t.*cos(t), t.*sin(t) )

% "tty" width and height
tty_w = 80;
tty_h = 24;

% marker style
marker = '*';

% prepare blank plot area
tty = repmat(' ', tty_h, tty_w);

% scale input data to tty size
xs = round(rescale(x, 1, tty_w));
ys = round(rescale(y, 1, tty_h));

% place markers onto plot area
tty(sub2ind(size(tty), ys, xs)) = marker;

% output plot
disp(flipud(tty));
