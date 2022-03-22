function x = get(X,index,match)
% Acquires data at index of X, where X is an ndimensional struct
%
% OPtionally will return only matching fieldnames

index = num2cell(index);
x = X(index{:});

if nargin > 2 && isstruct(match)
    matchfields = string(fieldnames(match));
    xfields = string(fieldnames(x));
    missingfields = setdiff(matchfields,xfields);
    deletefields = setdiff(xfields,matchfields);
    x = rmfield(x, deletefields);
    for field = missingfields(:)'
        x.(field)  = [];
    end
end
