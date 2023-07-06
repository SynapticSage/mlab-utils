function [result, status] = push(animal, dayDir, varargin)
% Pushes to a machine with rsync

ip = inputParser;
ip.addParameter('local', []);
ip.addParameter('remote', []);
ip.addParameter('test', false);
ip.addParameter('deleteExpensiveFolders', []); % can optionally be provided to instruct the function to delete expensive folders from the sender
ip.addParameter('ext_exclusions', ["mp4", "h264", "raw"]);
ip.parse(varargin{:})
Opt = ip.Results;

if isempty(Opt.local)
    error("Please provide local machine name");
end
if isempty(Opt.remote)
    error("Please provide remote machine name");
end
if Opt.test
    Opt.test = "--dry-run";
else
    Opt.test = [];
end

% Build remote folder string
to = rawdef(animal, 'machine', Opt.remote) + filesep + dayDir;
% Build local folder string
from = rawdef(animal, 'machine', Opt.remote) + filesep + dayDir;

% Build the exclusion list
if ~isempty(Opt.ext_exclusions)
    Opt.ext_exclusions = "--exclude ""*." + Opt.ext_exclusions + """";
end

% Build rsync phrase
phrase  = ["rsync --progress -avu", Opt.test, from, to]
phrase = join(phrase, " ");


% Hopefully this executes displaying text as it runs
[status, result] = system(phrase);
disp(result)

% remove expensive files?
if ~isempty(Opt.deleteExpensiveFolders)
    for search in string(Opt.deleteExpensiveFolders(:))'
        folders = dir("*." + search);
        isDir = arrayfun(@(x) x.isDir, folders, 'UniformOutput', false);
        isDir(1:2) = 0;
        folders = folders(isDir);
        if ~isempty(folders)
            for folder = folders
                files = dir(fullfile(folder.name, '*'));
                for file = files
                    %delete(file);
                end
            end
        end
    end
end
