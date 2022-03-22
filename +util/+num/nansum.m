function X = nansum(X, dim)
% potentially faster implementation of nansum

if nargin < 2
    dim = 1;
end

X = util.num.inplaceLogicalIndex(X, ~isnan(X), 0);
X = sum(X, dim);

