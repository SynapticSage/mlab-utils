function result = isEmptyRmField(X, fields)

if nargin == 1 || isempty(fields)
    fields = string(fieldnames(X));
    fields = fields(startwith(fields, 'dim'));
end

X      = rmfield(X, fields);
result = nd.isEmpty(X);
%result = nd.isEmpty(fields);
