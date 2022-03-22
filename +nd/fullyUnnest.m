function obj = fullyUnnest(obj, unnestAddressChar)
% Utilizes unnest() to fully unnest a hierarchiacl structure. This returns a
% flatted struct in such a way that all fields are numericals/strings etc from
% the leaves of a struct tree.

if nargin < 2
    unnestAddressChar = [];
end

structFields = @(x) util.struct.matchingfields(x, 'valueConditions', @isstruct);

for field = string(fieldnames(obj))'
    if isstruct(obj.(field))
        subfields = fieldnames(obj.(field));

        % Find struct fields and recursively call on fields
        sFields = structFields(obj.(field));
        for sField = sFields
            % sometimes we can still have a struct field not be one. this can
            % happen when field name appears multiple times in a struct tree,
            % both as a struct and as another type
            if ~isstruct(obj.(sField))
                continue 
            end
            obj.(sField) = nd.fullyUnnest(obj.(sField));
        end

        % Find non-struct fields
        nsFields = setdiff(subfields, sFields);
        if ~isempty(nsFields)
            obj = nd.unnest(obj, field, nsFields, unnestAddressChar);
        end
    end
end
