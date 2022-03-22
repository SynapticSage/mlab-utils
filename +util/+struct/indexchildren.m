function S = indexchildren(S, index, dim, varargin)
% function S = indexchildren(S, index, dim, varargin)

ip = inputParser;
ip.addParameter('condition', @(x) ~isstruct(x));
ip.parse(varargin{:})
Opt = ip.Results;

if nargin < 3
    dim = [];
end
if nargin < 2
    error("Must give index")
end

for field = getFieldnames(S)
    if Opt.condition(S.(field))
        S.(field) = indexItem(S.(field), index, dim);
    elseif isstruct(S.(field))
        S.(field) = util.struct.indexchildren(S, index, dim, Opt);
    elseif iscell(S.(field))
        for ii = 1:numel(S.(field))
            S.(field){ii} = util.struct.indexchildren(S.(field){ii}, index, dim, Opt);
        end
    end
end


%-------------------- HELPER FUNCTIONS --------------------------------
function S = indexItem(S, index, dim)

    if ~isempty(dim)
        ind = repmat(':', 1, ndims(S));
        ind = num2cell(ind);
        ind{dim} = index;
        S = S(ind{:});
    else
        S = S(index);
    end

function f = getFieldnames(x)

    f = string(fieldnames(x))';
