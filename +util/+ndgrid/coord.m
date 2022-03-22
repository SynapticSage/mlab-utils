function varargout = coord(X)

szX = size(X);
X = arrayfun(@(x) 1:x, szX, 'UniformOutput', false);
[X{:}] = ndgrid(X{:});

varargout = X;
