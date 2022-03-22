function Y = isfield(X, field, varargin)
% More flexible isfield. Allows type to be a cell of struct.

ip = inputParser;
ip.addParameter('how', 'any');
ip.parse(varargin{:})
Opt = ip.Results;

if iscell(X)
    if strcmp(Opt.how, 'any')
        Y = any(cellfun(@(x) ismember(field, fieldnames(x)), X));
    elseif strcmp(Opt.how, 'all')
        Y = all(cellfun(@(x) ismember(field, fieldnames(x)), X));
    else
        error("How is an unrecognized option")
    end
else
    Y = isfield(X, field);
end

