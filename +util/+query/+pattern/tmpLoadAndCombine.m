function [Patterns, otherData] = tmpLoadAndCombine(keys)
% Server analogue off loadAndCombine

kCount = 0;
for key = progress(keys(:)','Title','Remote->Local')
    kCount = kCount + 1;
    serverFile = fullfile(serverdefine, 'hash', key + ".mat");
    serverFile = serverFile.replace('//','/');
    localFile = fullfile('/','tmp', key+".mat");
    command = "rsync --partial --progress -avu " + serverFile + " " + localFile;
    disp(command);
    system(command);
end

otherData = cell(1,numel(keys));
kCount = 0;
P = cell(1,numel(keys));
for key = progress(keys(:)','Title','Loading keys')
    kCount = kCount + 1;
    tmp = load(localFile);
    P{kCount} = tmp.Patterns;
    tmp = rmfield(tmp,'Patterns');
    otherData{kCount} = tmp;
end

Patterns = ndb.toNd(squeeze(P));

