function atomicNPYfile(beh, vars, path2phy, varargin)

ip = inputParser;
ip.addParameter('nanval', -10);
ip.parse(varargin{:})
Opt = ip.Results;

if iscell(vars)
    Opt.nanval = vars{end};
    vars = string(vars(1:end-1));
end

subset = beh(:, vars);
subset = table2array(subset);
subset(isnan(subset)) = Opt.nanval;

if iscolumn(subset) || isrow(subset)
    dim = 1;
else
    dim = numel(size(subset));
end

filename = fullfile(path2phy, sprintf('spike_%s.npy', join(vars,"")));
util.npy.write(subset, filename, 'dim', dim);
