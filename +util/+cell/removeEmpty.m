function Tcell = removeEmpty(Tcell, varargin)

ip = inputParser;
ip.addParameter('fast', true);
ip.parse(varargin{:})
Opt = ip.Results;

if Opt.fast
    empty = cellfun(@isempty, Tcell);
else
    empty = cellfun(@nd.isEmpty, Tcell);
end
Tcell(empty) = [];
