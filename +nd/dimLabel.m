function results = dimLabel(results, dims, dimlabels, dimvalues)
% function results = dimLabel(results, dims, dimlabels, dimvalues)

% Optionally, just give labels, and we will assume dimensions 1..number ofo labels
if nargin == 2 && ...
        (iscellstr(dims) || isstring(dim))
    dimlabels = dims;
    dims = uint32(1:numel(dimlabels));
end

indices = nd.indicesMatrixForm(results);
dimlabels = string(dimlabels);
if nargin >= 4 && iscellstr(dimvalues)
    dimvalues = string(dimvalues);
end

d = 0;
for dim = dims
    d = d + 1;
    dimlabel = dimlabels(d);
    for index = indices'
        indexCell=num2cell(index);
        if nargin < 4
            dimval = indexCell{dim};
        else
            if isstring(dimvalues)
                dimval = dimvalues(indexCell{dim});
            else
                dimval = dimvalues{dim}(indexCell{dim});
            end
        end
        if iscell(results)
            if istable(results{indexCell{:}})
                results{ indexCell{:} }.(dimlabel) = ...
                    repmat(dimval, height(results{indexCell{:}}), 1);
            else
                results{ indexCell{:} }.(dimlabel) = dimval;
            end
        else
            results(indexCell{:}).(dimlabel) = dimval;
        end
    end
end
