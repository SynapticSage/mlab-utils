function frac = fractionQueryMatch(x, cond, dim)
%queries fraction of nunmbers matching a condition

if nargin < 2
    cond = @(x) ~isnan(x) & ~isinf(x);
end
if nargin < 3
    dim = 'all';
end

frac = mean(cond(x), dim);
