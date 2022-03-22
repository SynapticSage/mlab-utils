function tile(func, tiledim, varargin)
% Executes a plot function over tiles
% function tile(func, tiledim, varargin)

stringLoc = cellfun(@(x) isstring(x) || ischar(x), varargin);
if any(stringLoc)
    V = varargin(find(stringLoc):end);
    varargin(find(stringLoc):end) = [];
else
    V = {};
end
ip = inputParser;
ip.addParameter('kws', {});
ip.addParameter('squeeze', true);
ip.addParameter('errors', true);
ip.addParameter('limit', 0);
ip.addParameter('randomize', false);
ip.addParameter('runfuncs', {});
ip.parse(V{:})
Opt = ip.Results;

count = 0;
D = util.indicesMatrixForm(size(varargin{1}, tiledim))';
if Opt.randomize
    D = D(randperm(length(D)));
end
for d = progress(D)

    count = count + 1;
    if count == Opt.limit
        break;
    end

    ind = repmat(':', 1, ndims(varargin{1}));
    ind = num2cell(ind);
    ind{tiledim} = d;

    d = num2cell(d);
    nexttile(d{:});
    if Opt.squeeze
        V = cellfun(@(x) squeeze(x(ind{:})), varargin, 'UniformOutput',false);
    else
        V = cellfun(@(x) (x(ind{:})), varargin, 'UniformOutput',false);
    end
    try
        if ~iscell(func) && ~isstruct(func)
            func(V{:}, Opt.kws{:});
            if ~isempty(Opt.runfuncs)
                for f = Opt.runfuncs
                    f{1}();
                end
            end
        elseif iscell(func)
        elseif isstruct(func)
        end
    catch ME
        if Opt.errors
            throw(ME);
        end
    end

end
