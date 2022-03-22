function varargout = dimTensor(X)
% Outputs
% 1. a vector of indices per dimension
% 2. a ndgrid of indices per dimension

szX = size(X);
boundsX = arrayfun(@(x) 1:x, szX ,'uniformOutput', false);
if nargout > 1
    gridX = boundsX;
    [gridX{:}] = ndgrid(boundsX{:});
    varargout{2} = gridX;
end
varargout{1} = boundsX;
