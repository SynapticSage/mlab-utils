function obj = nest(obj, fields, nestfield)
% Nests fields into a new struct at nestfield

if isempty(fields)  % whenever this is empty, lets just assume people want all the fields
    fields = string(fieldnames(obj));
end

if ischar(nestfield) || iscellstr(nestfield)
    nestfield = string(nestfield);
end

for field = string(fields(:))'
    if isfield(obj,field)
        obj.(nestfield).(field) = obj.(field);
        obj = rmfield(obj, field);
    end
end
