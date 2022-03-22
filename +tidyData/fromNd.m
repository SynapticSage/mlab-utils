function T = fromNd(results, varargin)
% Make a tidy table from nd list of similar struct objects

ip = inputParser;
ip.addParameter('addConstArgs', {});
ip.addParameter('dimLabelArgs', {});
ip.addParameter('broadcast',    true);
ip.addParameter('ignore',    []);
ip.addParameter('ignoreType',    []);
ip.addParameter('stringify',    true);
ip.parse(varargin{:});
opt = ip.Results;

% If nd branch, then convert to nd struct
if iscell(results)
    results = ndBranch.toNd(results);
end

% Options to modify each struct
if ~isempty(opt.addConstArgs)
    results = nd.addConst(results, opt.addConstArgs{:});
end
if ~isempty(opt.dimLabelArgs)
    results = nd.dimLabel(results, opt.dimLabelArgs{:});
end
if ~isempty(opt.stringify)
    results = nd.stringify(results);
end

% Build super-table from table of each struct.
T = table();
first = 1;
P = ProgressBar(numel(results), 'Title','Converting to table');
for result = results(:)'
    if ~isempty(opt.broadcast)
        result = nd.broadcast(result);
    end
    t = tidyData.fromStruct(result,...
        'ignore', opt.ignore,...
        'ignoreType', opt.ignoreType);
    if height(t) == 0
        continue
    end
    T = [T; t];
    if  first == 1
        P.printMessage("Table with fields: " + join(T.Properties.VariableNames,", "));
        first = 0;
    end

    P.step([],[],[]);
end
