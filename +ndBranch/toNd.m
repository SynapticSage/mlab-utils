function results = toNd(obj,  varargin)
% Convert an nd branch structure to and nd struct

% Where are the values at?
clear results;
indices = ndBranch.indicesMatrixForm(obj);
innerindices = nd.indicesMatrixForm(ndb.get(obj, indices(1,:)));

% What should every empty struct be like?
results = nd.emptyLike(obj, varargin{:});

% Obtain each index and assing it the the struct nd array
for index = indices'
    I = index;
    I = num2cell(index);
    tmp = ndBranch.get(obj, index, results(1));
    for j_index = innerindices'
        J = j_index;
        J = num2cell(j_index);
        results(I{:},J{:}) = tmp(J{:});
    end
end

