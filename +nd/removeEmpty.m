function X = removeEmpty(X, dimfields)
% removeEmpty tests each element in X to see if its empty, ignoring dimfields,
% and the returns an X sanitized by removing empty elements.

if nargin == 1
    X = X(~arrayfun(@nd.isEmpty, X));
else
    X = X(~arrayfun(@(x) nd.isEmptyRmField(x,dimfields), X));
end
