function X = flexrmfield(X, fields)
% X = flexrmfield(X, fields)
%   Removes the fields from the struct X.  Fields can be a cell array of
%   strings or a single string.
%


if ischar(fields)
  fields = cellstr(fields);
end

fields = intersect(fields, fieldnames(X));

for i = 1:length(fields)
  X = rmfield(X, fields{i});
end
