function S = recursivelyReplaceField(S, from, to)
% Recursively eliminate a matched field throughout a struct, no matter how
% nested

for field = string(fieldnames(S))'
    if contains(field, from)
        S.(replace(field, from, to)) = S.(field);
        S = rmfield(S, field);
    elseif all(isa(S.(field), 'struct'))
        if isscalar(S.(field))
            S.(field) = ...
                util.struct.recursivelyReplaceField(S.(field), from, to);
        else
            for i = 1:numel(S.(field))
                S.(field)(i) = ...
                    util.struct.recursivelyReplaceField(S.(field)(i), from, to);
            end
        end
    end
end

