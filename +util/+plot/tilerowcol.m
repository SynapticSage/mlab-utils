function tile(func, rowtiledim, coltiledim, varargin)
% Executes a plot function over tiles
% function tile(func, tiledim, varargin)
%
% Can create axes of a function over row and column dimensions

stringLoc = cellfun(@(x) isstring(x) || ischar(x), varargin);

if any(stringLoc)
    V = varargin(stringLoc:end);
    varargin(stringLoc:end) = [];
else
    V = {};
end

ip = inputParser;
ip.addParameter('kws', {});
ip.parse(V{:})
Opt = ip.Results;

sz_varg = size(varargin{1});
rowcombos = util.indicesMatrixForm(size(sz_varg, rowtiledim))';
colcombos = util.indicesMatrixForm(size(sz_varg, coltiledim))';

for rowdim = rowcombos
for coldim = colcombos

    ind = repmat(':', 1, ndims(sz_varg));
    ind = num2cell(ind);

    ind{rowtiledim} = rowdim;
    ind{coltiledim} = coldim;

    r = ismember(rowdim', rowcombos', 'rows');
    c = ismember(coldim', colcombos', 'rows');

    d = ind2sub(sz_varg, r, c);
    nexttile(d);

    V = cellfun(@(x) squeeze(x(ind{:})), varargin, 'UniformOutput',false);
    if ~iscell(func) && ~isstruct(func)
        func(V{:}, Opt.kws{:});
    elseif iscell(func)
    elseif isstruct(func)
    end

end
end
