function T = icatNdb(X, varargin)
% When we have ndb of tidyData, this concatonates them

inds = ndb.indicesMatrixForm(X);
T = cell(size(inds,1), 1);
for i = 1:size(inds,1)
    ind = inds(i,:);
    T{i} = ndb.get(X, ind);
end

T = util.cell.icat(T, varargin{:});
