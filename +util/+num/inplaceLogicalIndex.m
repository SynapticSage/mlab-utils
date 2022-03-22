function X = inplaceLogicalIndex(X, index, emptyval)
% Performs an inplace logical index,
%
% X remains the same size, but all nontrue values are filled by an
% emptyval scalar

assert(islogical(index), 'index must be logical')
if ~isequal(size(index), size(X))
    index = logical(index .* true(size(X)));
end
if nargin < 3
    emptyval = nan;
end

X(~index) = emptyval;
