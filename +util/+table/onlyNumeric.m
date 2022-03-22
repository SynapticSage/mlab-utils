function T = onlyNumeric(T)
% Filter out all of the non-numeric columns

% Enumerate all non-numeric fields
removeFields = [];
for field = string(fieldnames(T))'
    if ~isnumeric(T.(field)) &&...
        ~ismember(field,["Properties","Row","Variables"])
        removeFields = [removeFields, field];
    end
end

% Delete all non-numeric fields
T(:,removeFields) = [];
