function obj = multiToSingleLevel(obj)
% Converts a multilevel table to a single level table

fields = fieldnames(obj);
while istable( obj.(fields(1)) )
    individual_tables = {};
    iField = 0;
    for field = fields
        iField = iField + 1;
        individual_tables{iField} = obj.(field);
    end
    obj = [individual_tables{:}]; % Horizontally concatonate
    fields = fieldnames(obj);
end
