function rows = query_logical(T, queryStr, varargin)
% Returns a logical of the matching rows for a query string

ip = inputParser;
ip.addOptional('columns',':', @(x) true);
ip.addParameter('debug', false)
ip.addParameter('arr',false); % convert to array?
ip.addParameter('recurseStruct',true); % If T is a struct, recurse?
ip.KeepUnmatched = true;
ip.parse(varargin{:});
Opt = ip.Results;

if ischar(queryStr)
    queryStr  = string(queryStr);
elseif iscell(queryStr) || ...
        (isstring(queryStr) && numel(queryStr)>1)
    queryStr = join(queryStr, ' & ');
end
queryStr = queryStr.replace('$','T.').replace('''','"');
if Opt.debug
    disp(queryStr);
end
rows = eval(queryStr);
