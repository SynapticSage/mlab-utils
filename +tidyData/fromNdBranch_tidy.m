function T = fromNdBranch_tidy(X, varargin)

ip = inputParser;
ip.addParameter('labels',[]);
ip.addParameter('dimLabel',[]);
ip.addParameter('datatype',[]);
ip.parse(varargin{:})
opt = ip.Results;

% Determine any labels
if ~isempty(opt.dimLabel)
    labels = opt.dimLabel;
elseif ~isempty(opt.labels)
    labels = opt.labels;
elseif ~isempty(opt.datatype)
    labels = ndbFile.datatypeLevels(opt.datatype);
else 
    labels = [];
end
labels = string(labels);
assert(isequal(ndBranch.type(X), 'table'))

indices = ndBranch.indicesMatrixForm(X);

T = table();
for index = indices'
    t = ndBranch.get(X, index);
    if ~isempty(labels)
        t = label(t, index, labels);
    end
    T = [T; t];
end

function t= label(t, index, labels)
    m = min(numel(labels),numel(index));
    for i = 1:m
        t.(labels(i))  = repmat(index(i),height(t),1);
    end
