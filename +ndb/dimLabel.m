function results = dimLabel(results, dims, dimlabels, dimvalues)
% function results = dimLabel(results, dims, dimlabels, dimvalues)
%
% Optionally, just give labels, and we will assume dimensions 1..number of labels
% 

if nargin == 2 && ...
        (iscellstr(dims) || isstring(dim))
    dimlabels = dims;
    dims = 1:numel(dimlabels);
end

indices = ndb.indicesMatrixForm(results);
dimlabels = string(dimlabels);

for index = progress(indices')
    result = ndb.get(results, index);
    d = 0;
    for dim = dims % TODO inner and outer loops should switch for O() efficiency
        d = d + 1;
        dimlabel = dimlabels(d);
        indexCell=num2cell(index);
        if nargin < 4
            dimval = indexCell{dim};
        else
            if isstring(dimvalues)
                dimval = dimvalues(indexCell{dim});
            else
                dimval = dimvalues{indexCell{dim}};
                %if iscell
                %    dimval = dimvalues{dim}{indexCell{dim}};
                %else
                %    dimval = dimvalues(indexCell{dim});
                %end
            end
        end
        if istable(result)
            result.(dimlabel) = ...
                repmat(dimval, height(results{indexCell{:}}), 1);
        else
            result.(dimlabel) = dimval;
        end
    end
    results = ndb.set(results, index, result);
end
