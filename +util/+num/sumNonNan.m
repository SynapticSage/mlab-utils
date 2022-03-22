function S = sumNonNan(X, dim)
%sums non-nan entries along dimension

if nargin < 2
    dim = 'all';
end

S = sum(~isnan(X), dim);
