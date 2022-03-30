function [out, Opt] = prepareOuts(spikes, groupby, shifts, groups, Opt)
% SET UP OUTPUTS 
%
% ------
% Inputs
% ------
%
% -------
% Outputs
% -------

disp("Prepping output medium")
tic

% Setup outfolder
% ---------------
if isempty(Opt.outfolder)
    switch Opt.cacheMethod
    case 'parquet'
        if isempty(Opt.cacheToDisk)
            error('Must provide arguments to coding.file.parquetfolder as a cell array passed to Opt.cacheToDisk')
        end
        Opt.outfolder = coding.file.parquetfolder(Opt.cacheToDisk{:});
    end
end

refreshCache = (~Opt.skipShuffled && Opt.startShuffle ~= 1);

if strcmp(Opt.cacheMethod, 'parquet') && refreshCache
    disp("Refreshing parquet cache")
    % Remove any former shuffle data
    for file = dir(fullfile(Opt.outfolder), '*.parquet')'
        delete(fullfile(file.folder, file.name));
    end
elseif strcmpi(Opt.cacheMethod, 'matfile') && refreshCache
    disp('Deleting and refreshing matfile cache')
    delete(coding.file.shufflematfilename(Opt.cacheToDisk{:}, Opt));
end

% Setup struct
% ---------------
switch Opt.cacheMethod
case 'matfile'
    Opt.writable = true;
    out = coding.file.shufflematfile(Opt.cacheToDisk{:}, Opt);
    disp("Shuffle file path => " + out.Properties.Source);
case 'parquet'
    out = struct();
otherwise
    out = struct();
end
out.groupby = groupby;
out.Groups = groups;
out.nShuffle = Opt.nShuffle;
out.nNeurons = height(spikes.cellTable);
out.nGroups  = groups.nGroups;
out.shifts = shifts;
out.shifttype = Opt.shifttype;
out.shiftWhat = Opt.shiftWhat;
out.shiftstatistic = Opt.shiftstatistic;
out.shufflename = Opt.shufflename;
if ~isempty(Opt.query)
    Opt.query = Opt.query;
else
    Opt.query = '';
end
if isfield(Opt, 'writable'); Opt = rmfield(Opt, 'writable'); end
out.Opt = Opt;
toc
