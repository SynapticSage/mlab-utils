function save(variable, animal, datatype, varargin)
% Save nd branch structure.
% dim : signals how to break the nd branch file
%
% Outstanding ISSUES:
% - If one of the branch dimensions is "padded" with empty cells (ie empty
% cells many indices beyond data cells) these may not be saved

ip = inputParser;
ip.addOptional('dim',1);
ip.KeepUnmatched = true;
ip.addParameter('backup',false,...
    @(x) islogical(x) || ismember(x,[0,1]));
ip.addParameter('asNd', false);
ip.parse(varargin{:});
opt = ip.Results;
opt.animal = animal;

folder = ndbFile.folder(animal, datatype, ip.Unmatched);

if istable(variable)
    Params = ip.Unmatched;
    Params.datatype = datatype;
    variable = ndb.fromTidy(variable, [], Params);
end
if iscell(variable)
    indices   = ndBranch.indicesMatrixForm(variable);
else
    indices   = nd.indicesMatrixForm(variable);
    variable  = nd.toNdBranch(variable);
end
assert(iscell(variable),...
    'Must at this point be ndBranch')

% Make an empty nd struct just like the variable
empty = {};

% Enumerate all indices
[~, ~, iUns] = unique(indices(:,1:opt.dim),'rows');

% Iterate over each unique cut of the data and save it
for iU = unique(iUns)'

    % Make the nd object for this cut
    thisCycle = empty;
    for row = find(iU == iUns)'
        I = indices(row,:);
        thisCycle = ndBranch.set(thisCycle, I, ndBranch.get(variable, I));
    end

    % Determine the name for this cut
    name = string(sprintf('%s%s',opt.animal,datatype));
    inds = indices(row, 1:opt.dim);
    if opt.dim > 0
        name = name + sprintf('%02d', inds(1));
        inds(1) = [];
        while ~isempty(inds)
            name = name + "-" + sprintf('%02d', inds(1));
            inds(1) = [];
        end
    end
    
    % Save this cut of data
    if opt.asNd
        thisCycle = ndBranch.toNd(thisCycle);
    end

    if ~exist(folder,'dir'); mkdir(folder); end
    m = matfile(fullfile(folder, name + ".mat"), 'Writable', true);
    m.(datatype) = thisCycle;
end
