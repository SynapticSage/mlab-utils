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
ip.addRequired('saveFlags', {'-v7.3', '-uncompressed'});
ip.parse(folder,varargin{:});
Opt = ip.Results;

curr_dir = pwd;
c = onCleanup(@()cd(curr_dir));

if exist(folder,'dir')
    search = '*.mat';
else
    [folder,search]=fileparts(folder);
    if isempty(folder); folder=pwd; end
end

try

    pushd(folder);
    f = onCleanup(@() popd());
    M = dir(search);
    for m = 1:numel(M)
        
        filename = M(m).name;
        fprintf('(%2.2f) Converting %s\n',100*m/numel(M),filename);
        dat = load(filename);

        try
            save(filename, '-struct', 'dat', Opt.saveFlags);
        catch % if file is too big to be uncompressed, then go ahead and recompress it into v7.3
            warning('Could not save file %s as uncompressed.  Saving as v7.3 instead.',filename);
        end
        
        clear dat;
        
    end

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
