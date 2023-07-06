function recursiveResave(folder, varargin)
% recursiveResave(folder)
%
%   Recursively walks through a folder and all subfolders reseaving all
%   mat files in the folder with special flags.  This can be used, for
%   compressing mat files that have been saved in the v7.3 format to the
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
ip.addParameter('castefficient', true, @islogical); % cast to most efficient type
ip.addParameter('castefficient_args', {'compressReals',true}); % cast to most efficient type arguments
ip.addParameter('lambda', []); % lambda function
ip.addParameter('lambda_args', {}); % lambda function arguments
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
        disp("Checking file " + string(filename));

        if any(contains(filename,Opt.contain_exclude))
            disp("...skipping file...");
            continue;
        end
        if regex_mode
            for e = 1:numel(Opt.exclude)
                if regexp(filename,Opt.exclude{e})
                    disp("...skipping file...");
                    continue;
                end
            end
        elseif any(strcmp(filename,Opt.exclude))
            disp("...skipping file...");
            continue;
        end

        fprintf(' Loading %s\n',filename);
        dat = load(filename);

        if ~isempty(Opt.lambda)
            disp("...running lambda function...");
            dat = lambda(dat);
        end

        if Opt.castefficient
            disp("...casting to most efficient type...");
            dat = util.type.castefficient(dat, Opt.castefficient_args{:});
        end

        try
            disp("...saving file...");
            initialFileSize = dir(filename).bytes;
            save(filename + "-tmp.mat", '-struct', 'dat', Opt.saveFlags{:});
            movefile(filename + "-tmp.mat", filename, 'f');
            finalFileSize = dir(filename).bytes;
            disp("...previous size was " + string(initialFileSize) + " bytes, new size is " + string(finalFileSize) + " bytes...");
        catch e % if file is too big to be uncompressed, then go ahead and recompress it into v7.3
            keyboard;
            disp("Caught exception while saving file");
            dConvertingisp(e.identifier);
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
