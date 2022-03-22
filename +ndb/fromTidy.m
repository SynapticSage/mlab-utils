function scaffold = fromTidy(X, level, varargin)
% Converts table into ndbranch of tidy data

ip = inputParser;
ip.addParameter('labels',[]);
ip.addParameter('datatype',[]);
ip.parse(varargin{:});
Opt = ip.Results;

if ~isempty(Opt.labels)
    labels = Opt.labels;
elseif ~isempty(Opt.datatype)
    labels = ndbFile.datatypeLevels(Opt.datatype);
else
    labels = [];
end

if isempty(level)
    level = numel(labels);
end

indices = table2array(X(:, labels(1:level)));
uInds = unique(indices, 'rows');

scaffold = {};
for uInd = uInds'
    filt = ismember(indices, uInd(:)', 'rows');
    x = X(filt,:);
    scaffold = ndb.set(scaffold, uInd,  x);
end
