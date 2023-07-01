function X = nestedFieldCat(X, nestedFields, dim)
% X = nestedFieldCat(X, nestedFields, dim)
%
% Concatenate nested fields of a struct array.
%
% INPUTS
%   X            Struct array
%   nestedFields Cell array of strings. Each string is a field name of X.
%   dim          Dimension along which to concatenate. If not given, the
%                dimension is inferred from the size of the nested fields.
%
% OUTPUTS
%   X            Struct array with concatenated fields.

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
