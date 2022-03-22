function X = nestedFieldCat(X, nestedFields, dim)
%

dim_not_given = nargin < 3;
store = cell(1, numel(X));
for i = 1:numel(X)
    XX = X(i);
    for field = nestedFields
        XX  = XX.(field);
    end
    store{i} = XX;
    if dim_not_given
        dim = ndims(XX) + 1;
    end
end

X = cat(dim, store{:});
