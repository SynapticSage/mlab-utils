function value = get(obj, index, match)
% Get value of a branched cell at an index
% (opt) if value is a struct, match a structure format

I = index;
value = obj;
while numel(I)>0
    [i,I] = pop(I);
    value = value{i};
end

if nargin > 2 && isstruct(match)
    matchfields = string(fieldnames(match));
    valuefields = string(fieldnames(value));
    missingfields = setdiff(matchfields,valuefields);
    deletefields = setdiff(valuefields,matchfields);
    value = rmfield(value, deletefields);
    for field = missingfields(:)'
        innerindices = nd.indicesMatrixForm(value);
        for index = innerindices'
            I = num2cell(index);
            value(I{:}).(field)  = [];
        end
    end
end

function [i,I] = pop(I)
i = I(1);
I = I(2:end);
