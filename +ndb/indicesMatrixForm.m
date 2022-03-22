function indices = indicesMatrixForm(obj)
% returns indices of every possible struct with data

indices = [];
indexcount = 0;

% if (nargin < 2)
%     currBranchInd = [];
% end

notACell = @(x) isstruct(x) || isnumeric(x) || islogical(x) || iscellstr(x) || isstring(x) || ischar(x) || istable(x);

if iscell(obj)
    for i = 1:length(obj)
        if notACell(obj{i})
            if nd.isEmpty(obj{i})
                continue
            end
            indexcount = indexcount + 1;
            indices(indexcount,1) = i;
        elseif iscell(obj{i})
            branchIndices = ndBranch.indicesMatrixForm(obj{i});
            numentries = size(branchIndices,1);
            branchIndices = [repmat(i,[numentries,1]) branchIndices];
            indices(indexcount+1:indexcount+numentries,1:size(branchIndices,2)) = branchIndices;
            indexcount = indexcount+numentries;
        end
    end
end

indices(any(indices == 0,2),:) = [];
