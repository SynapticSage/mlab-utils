function E = exist(animID, datatype, index)
% True if a file with the animID, datatype, level exists

if nargin < 3
    index = [];
end
if nargin < 2
    datatype ="";
end

folder = ndbFile.folder(animID, datatype);

if isempty(index)
    E = ~isempty(dir(fullfile(folder, sprintf('%s%s*',animID,datatype))));
else
    E = ~isempty(ndbFile.files([string(animID), string(datatype)], index, [], 'typeNotExistHandling', 'empty'));
end

