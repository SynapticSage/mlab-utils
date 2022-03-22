function S = recursivelyEliminateMatch(S, match)
% Recursively eliminate a matched field throughout a struct, no matter how
% nested

for field = string(fieldnames(S))'
    if strcmp(field, match)
        S = rmfield(S, field);
    elseif all(isa(S.(field), 'struct'))
        if isscalar(S.(field))
            S.(field) = ...
                util.struct.recursivelyEliminateMatch(S.(field), match);
        else
            for i = 1:numel(S.(field))
                S.(field)(i) = ...
                    util.struct.recursivelyEliminateMatch(S.(field)(i), match);
            end
        end
    end
end

