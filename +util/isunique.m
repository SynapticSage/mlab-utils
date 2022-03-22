function u = isunique(x, matrixmode)

if nargin == 1
    matrixmode = false;
end

if ismatrix(x) && matrixmode
    u = arrayfun(@(c) util.isunique(x(:,c)), 1:size(x,2));
else
    u = numel(x) == numel(unique(x));
end
