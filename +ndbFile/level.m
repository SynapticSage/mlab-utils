function L = level(file)
% Returns how many dimensions in a ndBranched cell file
% Example
% RY16lfp01-02-14.mat would be 3
% RY4pos01.mat would be 1

if contains(file, "*")
    file = dir(file);
    file = {file.name};
    file = file{1};
end

L = numel(ndbFile.index(file));
