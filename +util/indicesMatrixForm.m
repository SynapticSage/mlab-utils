function D = indicesMatrixForm(sz, sortOrderOutToIn)
% function D = indicesMatrixForm(sz)
%
% Generalizes indicesMatrixForm to just a size input, rather than providing the
% actual object in the nd.indicesMatrixForm and ndb.indicesMatrixForm functions
if nargin == 1
    sortOrderOutToIn = true;
end

d = arrayfun(@(x) 1:x, sz, 'UniformOutput' , false);
D = cell(size(d));
[D{:}] = ndgrid(d{:});
D = cellfun(@(x) x(:), D, 'UniformOutput', false);
D = cat(2, D{:});
if sortOrderOutToIn
    D = sortrows(D, 1:numel(sz));
end
