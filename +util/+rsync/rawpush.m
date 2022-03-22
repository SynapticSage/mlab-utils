function [result, status] = rawpush(animal, dayDir, varargin)
% Pushes to a machine with rsync

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('local', []);
ip.addParameter('remote', []);
ip.addParameter('test', false);
ip.addParameter('deleteExpensiveFolders', []); % can optionally be provided to instruct the function to delete expensive folders from the sender
ip.addParameter('recycle', false);
ip.addParameter('ext_exclusions', ["mp4", "h264", "raw"]);
ip.addParameter('mountainsort',  true);
ip.addParameter('clearMountainsort', true);
ip.addParameter('verbose', true);
ip.parse(varargin{:})
Opt = ip.Results;

% File recycle state
recycle_state = recycle();
restoreState = onCleanup(@() recycle(recycle_state));
if Opt.recycle == true
    Opt.recycle == "on";
elseif Opt.recycle == false
    Opt.recycle = "off";
end
recycle(Opt.recycle);

% Check inputs
if isempty(Opt.local)
    error("Please provide local machine name");
end
if isempty(Opt.remote)
    error("Please provide remote machine name");
end
if Opt.test
    Opt.test = "--dry-run";
    test = true;
else
    Opt.test = [];
    test = false;
end

% Build remote folder string
from = rawdef(animal, 'machine', Opt.local) + filesep + dayDir;
% Build local folder string
to = rawdef(animal, 'machine', Opt.remote) + filesep;

% Build the exclusion list
if ~isempty(Opt.ext_exclusions)
    Opt.ext_exclusions = "--exclude ""*." + Opt.ext_exclusions + """";
end

% Build rsync phrase
phrase  = ["rsync --progress -avuL", Opt.test, Opt.ext_exclusions, from, to];
phrase = join(phrase, " ");


% Hopefully this executes displaying text as it runs
if Opt.verbose; disp(phrase); end;
[status, result] = system(phrase, '-echo');
%if Opt.verbose; disp(result); end;

% Remove expensive files?
if ~isempty(Opt.deleteExpensiveFolders)
    for search = string(Opt.deleteExpensiveFolders(:))'
        folders = dir(from + filesep + "*." + search);
        if isempty(folders)
            continue
        end
        isDir = arrayfun(@(x) x.isdir, folders, 'UniformOutput', true);
        folders = folders(isDir);
        if ~isempty(folders)
            for folder = folders'

                % Find files and remove
                files = dir(fullfile(folder.folder, folder.name, '*'));
                for file = files(3:end)'
                    toDelete = fullfile(folder.folder, folder.name, file.name);
                    if Opt.verbose; disp("Deleting " + toDelete); end
                    if ~test
                        delete(toDelete);
                    end
                end

                % Remove folder
                toDelete = fullfile(folder.folder, folder.name);
                if Opt.verbose; disp(toDelete); end
                if ~test
                    delete(toDelete);
                end
            end
        end
    end
end

% Handle mountainsort files
if Opt.mountainsort
    animalfolder = animaldef(animal);
    msfolder = string(fullfile(animalfolder{2}, 'MountainSort')).replace([filesep, filesep], filesep);
    from = msfolder + filesep + "*";
    to = fullfile(to, "..", animal + "_direct", 'MountainSort').replace([filesep, filesep], filesep) + filesep;
    if Opt.clearMountainsort
        deletionTag = "--remove-source-files";
    else
        deletionTag = "";
    end
    phrase = ["rsync -avuL ", Opt.test, deletionTag, from, to];
    phrase = join(phrase, " ");
    if Opt.verbose; disp(phrase); end
    [msstatus, msresult] = system(phrase, '-echo');
    %if Opt.verbose; disp(msresult); end
end
