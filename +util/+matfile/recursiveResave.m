function recursiveResave(folder, varargin)
% recursiveResave(folder)
%
%   Recursively walks through a folder and all subfolders converting all
%   mat files to the latest version of mat file format.  This can be used
%   to compress mat files that have been saved in the v7.3 format to the
%   uncompressed v7.3 format.  Or can be used to convert mat files from
%   v6 to v7.3.
%
%   Inputs:
%       folder: folder to begin recursive crawl through.  If no folder is
%       provided, the current working directory is used.
%
%   Outputs:
%       None
%
%   Examples:
%       recursiveMatFileConversion('C:\Users\Me\Desktop\MyData');
%           - This will convert all mat files in the folder
%             'C:\Users\Me\Desktop\MyData' to the latest mat file format
%             (currently v7.3).
%
%       recursiveMatFileConversion;
%           - This will convert all mat files in the current working
%             directory to the latest mat file format (currently v7.3).
%
%   See also:
%       save, load
%
%   Required Files:
%       +none

ip = inputParser();
ip.addParameter('saveFlags', {'-v7.3', '-nocompression'});
ip.addParameter('exclude', {}, @iscellstr);
ip.addParameter('contain_exclude', {}, ...
    @(x) iscellstr(x) || ischar(x) || isstring(x));
ip.addParameter('lambda', []); % lambda function
ip.parse(varargin{:});
Opt = ip.Results;

curr_dir = pwd;
c = onCleanup(@()cd(curr_dir));

if exist(folder,'dir')
    search = '*.mat';
else
    [folder,search]=fileparts(folder);
    if isempty(folder); folder=pwd; end
end

regex_mode = any(contains(Opt.exclude, "*"));

try

    % Convert all mat files in current folder
    pushd(folder);
    f = onCleanup(@() popd());
    M = dir(search);
    for m = progress(1:numel(M), 'Title', 'Converting mat files')
        
        filename = M(m).name;

        if any(contains(filename,Opt.contain_exclude))
            continue;
        end
        if regex_mode
            for e = 1:numel(Opt.exclude)
                if regexp(filename,Opt.exclude{e})
                    continue;
                end
            end
        elseif any(strcmp(filename,Opt.exclude))
            continue;
        end

        fprintf(' Converting %s\n',filename);
        dat = load(filename);
        if ~isempty(Opt.lambda)
            disp("...running lambda function...");
            dat = lambda(dat);
        end

        try
            save(filename, '-struct', 'dat', Opt.saveFlags{:});
        catch e % if file is too big to be uncompressed, then go ahead and recompress it into v7.3
            disp("Caught exception while saving file");
            disp(e.identifier);
            disp(e.message);
            warning("Could not save file " + string(filename) + " with flags " + join(Opt.saveFlags, ", ") + ".");
        end
        
        clear dat;
        
    end

    % Recursively crawl through subfolders
    clear d D;
    D = dir();
    for d = 3:numel(D)
        
        file = D(d);
        
        if file.isdir
            util.matfile.recursiveResave(fullfile(pwd,file.name,search));
        end
    end

catch ME
    warning('Caught non-save issue exception in recursive crawl');
    cd(curr_dir);
    rethrow(ME);
end
