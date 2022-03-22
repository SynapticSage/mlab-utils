function [X,Y] = toFigUnits(x,y)
% Projects x,y data points into noramlized figure units [0,1]. Useful for e.g. the annotation function.

pos = get(gca, 'Position');
xlim = get(gca, 'xlim');
ylim = get(gca, 'ylim');
if strcmp(get(gca,'ydir'),'reverse')
    pos(2) = pos(2)+pos(4);
end

X = [(x(1) + abs(min(xlim)))/diff(xlim) * pos(3) + pos(1),...
     (x(2) + abs(min(xlim)))/diff(xlim) * pos(3) + pos(1) ];
if strcmp(get(gca,'ydir'),'reverse')
Y = [-(y(1) - min(ylim))/diff(ylim) * pos(4) + pos(2),...
     -(y(2) - min(ylim))/diff(ylim) * pos(4) + pos(2)];
else
Y = [(y(1) - min(ylim))/diff(ylim) * pos(4) + pos(2),...
     (y(2) - min(ylim))/diff(ylim) * pos(4) + pos(2)];
end

