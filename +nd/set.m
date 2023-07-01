function X = set(X, ind, x)
%SET Set a value in a tensor.
%
%   SET(X,IND,X0) sets the element of X at the specified index to the
%   value X0.  The index IND can be a scalar or a vector.

if ~iscell(ind)
    ind = num2cell(ind);
end
try
    X(ind{:}) = x;
catch
    % If we have an error, try the flexible set
    X = nd.flexset(X, ind, x);
end
