function X = set(X, ind, x)

if ~iscell(ind)
    ind = num2cell(ind);
end
try
    X(ind{:}) = x;
catch
    % If we have an error, try the flexible set
    X = nd.flexset(X, ind, x);
end
