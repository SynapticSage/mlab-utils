function I = findMatrixForm(X);
% Returns a matrix form of the indices of n-dimensional logical X ~= 0
%
% If X is a logical, performs find on logical given
% and returns valid subscripts in matrix form.
%
% If X is a cell or an array, returns non-empty locations
% as defined by nd.isEmpty

if ~islogical(X);
    if iscell(X)
        X = ~cellfun(@nd.isEmpty, X);
    else
        X = ~arrayfun(@nd.isEmpty, X);
    end
end
I = find(X);
dimension_wise = cell(1,ndims(X));

[dimension_wise{:}] = ind2sub(size(X), I);
I = cat(2,dimension_wise{:})
