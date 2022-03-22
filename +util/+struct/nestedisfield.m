function answer = nestedisfield(X, fields)

if iscellstr(fields)
    fields = string(fields);
end

answer = false;
if ~isstruct(X)
    answer = true; %found
elseif isfield(X, fields(1))
    answer = util.struct.nestedisfield(X.(fields(1)), fields(2:end));
end
