function T = fromNd(results, varargin)
% Make a tidy table from nd list of similar struct objects
%
% T = tidyData.fromNd(results, varargin)
%
% Inputs
%   results - nd list of struct objects
%
% Optional key/value pairs
%   'addConstArgs' - cell array of key/value pairs to pass to nd.addConst
%   'dimLabelArgs' - cell array of key/value pairs to pass to nd.dimLabel
%   'broadcast'    - true/false (default true). If true, then broadcast
%                    each struct to the same size before converting to table
%   'ignore'       - cell array of field names to ignore
%   'ignoreType'   - cell array of field types to ignore
%   'stringify'    - true/false (default true). If true, then convert all
%                    fields to strings

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
