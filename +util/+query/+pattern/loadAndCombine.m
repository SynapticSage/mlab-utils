function [Patterns, otherData] = combinePatterns(keys)
% Takes a list of keys and loads into combined pattern across keys
%
% final shape : keyCount x partitions x direction x patterns

kCount = 0;
P = cell(1,numel(keys));
otherData = cell(1,numel(keys));
for key = progress(keys(:)','Title','Loading keys')
    kCount = kCount + 1;
    tmp = load(fullfile(datadefine, 'hash', key + ".mat"));
    P{kCount} = tmp.Patterns;
    tmp = rmfield(tmp,'Patterns');
    otherData{kCount} = tmp;
end

Patterns = ndb.toNd(squeeze(P));
