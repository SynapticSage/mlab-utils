function results = simplebroadcast(results, varargin)
% function results = broadcast(results, varargin)
%BROADCAST Broadcast each field of the struct to match other fields

ip = inputParser;
ip.addParameter('nonVectorExpand', true);
ip.parse(varargin{:})
Opt = ip.Results;


% FIND THE FIELDS THAT REPRESENT THE COORDINATE SYSTEM
% ----------------------------------------------------

isVector = structfun(@(x) find(numel(x) == size(x)), results, 'UniformOutput', false);

fieldlist = string([]);
order = [];
for field = string(fieldnames(isVector)')
    if ~isempty(isVector.(field))
        order(end+1) = isVector.(field);
        fieldlist(end+1) = field;
    end
end
order = order(:);
fieldlist = fieldlist(:);
tab = table(order, fieldlist);
tab = sortrows(tab, 'order');

collect = cell(1, height(tab));
for ii = 1:height(tab.fieldlist)
    collect{ii} = results.(tab.fieldlist(ii));
end

% Broadcast coordinates
% ---------------------
[collect{:}] = ndgrid(collect{:});

% Redistribute
% ------------
for ii = 1:height(tab.fieldlist)
    results.(tab.fieldlist(ii)) = collect{ii};
end

if Opt.nonVectorExpand
    item = results.(tab.fieldlist(1));
    broadcaster = ones(size(item));
    for field = string(fieldnames(results))'
        results.(field)  = bsxfun(@times, broadcaster, results.(field));
    end
end
