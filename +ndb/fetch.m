function varargout = fetch(x, fields)
% Like cellfetch, but instead can fetch mulitiple fields and fetches them into
% shape matched nd arrays
%
% input
% x :: n-dimensional branched cell
% fields :: char, string, or cell of char

assert(isstring(fields) ||  ischar(fields)  || iscellstr(fields),...
    'Error: fields must be char, strings, or cell of char');

fields  = string(fields);

if iscell(x)
    x = ndBranch.toNd(x);
else
    error("Use nd.fetch() instead! Did not pass an ndBranch structure");
end

varargout = cell(1,2*numel(fields));
fcount = 0;
indices = cell(1, numel(fields));
for field = fields(:)'
    fcount = fcount + 1;
    y = {x.(field)};
    y = reshape(y(:), size(x));
    indices{fcount} = nd.findMatrixForm(~cellfun(@nd.isEmpty, y));
    try
        y = cell2mat(y);
    catch ME
    end
    varargout{fcount} = y;
end

if isequal(indices{:})
    varargout{fcount+1} = indices{1};
else
    indices = nan;
end
 

%indices = nd.indicesMatrixForm(x);
%varargout{fcount+1} = indices;
