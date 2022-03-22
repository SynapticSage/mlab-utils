function T = structs(results, varargin)
% Make a tidy table from nd list of similar struct objects

ip = inputParser;
ip.addParameter('addConstArgs', {});
ip.addParameter('dimLabelArgs', {});
ip.addParameter('broadcast',    true);
ip.parse(varargin{:});
opt = ip.Results;

if ~isempty(opt.addConstArgs)
    results = nd.addConst(results, opt.addConstArgs{:});
end
if ~isempty(opt.dimLabelArgs)
    results = nd.dimLabel(results, opt.dimLabelArgs{:});
end
if ~isempty(opt.broadcast)
    results = nd.broadcast(results);
end

T = table();
for result = results(:)'
    t = tidyData.struct(result);
    T = [T; t];
end