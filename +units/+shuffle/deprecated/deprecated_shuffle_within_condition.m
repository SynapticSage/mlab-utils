function [out, groups] = deprecated_shuffle_within_condition(beh, spikes, groupby, varargin)
% Circularly shuffles within times per some conditioned group
%
%
% Uses:
% (1) Sarel 2017 and Dotson 2021 each requires circular spike time shuffles
% within trials. Doable by setting groupby to your relevent trial var name in
% the behavior table.
%
% -------
% Inputs
% -------
% 
% beh : table-type
%   This is a time length table, where columns are properties of the animal's
%   behavior
%
% spikes : struct
%   This is the spikes struct emitted by the units.getRate() method. It contains
%   all of the information that we will use about spiking
%
%
% groupby : list[string]
%   This is a list of propertiees to shuffle within. We shuffle within the
%   logical and of unique elements of these properties.
%
%
% ---------
% Optionals
% ---------
%
% Descriptions of the optional inputs can be found in the optional section 
% below.
%
% -------
% Outputs
% -------
%
% out : 
%
%   contains the ram or matfile based cache if those methods are seelceteed
%
% groups : 
%
%   the groups struct from util.findgroups(beh, props)
%
% -----
% Notes
% -----
%
%
% This is an extremely flexible method that can be used for overall shuffles
% or within property
%
% If you're using a shifts property in your shuffles, be aware that the set of
% tables can be very large. 100 shuffles of just x/y/time data for all neurons
% takes up 70GB on my machine. if you have those shuffles resampled for time-shifts
% (not shuffle-time shifts, but time-shifts as in the dotson and yartsev paper), 
% then you will take up 1400GB of space.
% 
% In order to scale to that level, there's an option for the atBehavior method
% that allows returning the indices of the beh table to sample rather
% than the actual behavior/time at those indices. This is a much more compressed
% way of doing things.

%                                              
%                     ,---.     |    o          
%                    |   |,---.|--- .,---.,---.
%                    |   ||   ||    ||   ||   |
%                    `---'|---'`---'``---'`   '
%                         |                    
ip = inputParser;
ip.KeepUnmatched = true; % Any UNMATCHED go to the called method units.atBehavior.m
% Usual params for that: 

% CHARACTERISTICS OF THE SHUFFLE
ip.addParameter('shuffleCount', 100, @isnumeric);
ip.addParameter('shuffleunits', 'unitwise'); % shuffle neurons so that {unitwise}|uniform
ip.addParameter('shiftstatistic', 'uniform'); % what statistic of shift? {uniform}|normal
ip.addParameter('width', 'whole'); % draw the 'whole' period of time, or some specified amount or standard deviation
ip.addParameter('shiftWhat', 'behavior'); % It's equibalent to shift behavior times repeatedly per cell or spike times per cell, but my estimate is that it's less memory intense for behavior


% SAVE space?
ip.addParameter('throwOutNonGroup', false);
ip.addParameter('preallocationSize', 100); % number of shuffles to run at a time
ip.addParameter('props',[]);
ip.addParameter('dropGroupby', true);
ip.addParameter('cacheToDisk', {}); % if out to disk, this takes the parameters for coding.file.shufflefilename or coding.file.parquetfoldername
ip.addParameter('cacheMethod', 'parquet'); 
ip.addParameter('groups', []);
%ip.addParameter('lazy', false); % instead save the parameters needed to yield shuffles on the fly

ip.parse(varargin{:})
Opt = ip.Results;
Opt.shuffleunits   = string(Opt.shuffleunits);
Opt.shiftstatistic = char(Opt.shiftstatistic);

kws_atBehavior = ip.Unmatched;

if ~isempty(Opt.props)
    Opt.props = union("time", string(Opt.props));
    Opt.props = union(groupby, string(Opt.props));
    beh = beh(:, Opt.props);
end

                                    
%                     ,-.-.     o     
%                     | | |,---..,---.
%                     | | |,---|||   |
%                     ` ' '`---^``   '
%----------------------------------------
% Create set of shuffle times
%----------------------------------------
% S x G x 1 if uniform or S x G x N if unit-based
if isempty(Opt.groups)
    groups = util.table.findgroups(beh, groupby);
else
    groups = Opt.groups;
end
if Opt.dropGroupby
    beh(:, groupby) = [];
end

checksum = all(ismember(unique(diff(groups.time.groups(groups.time.groups~=-1))), [0,1]));
assert(checksum, 'Non-contiguous regions in your conditionals!')

[measure] = measuretimeperiods(Opt);
[shifts] = calculateshifts(measure, Opts);
[out, outfolder] = prepareOuts(Opt);

switch Opt.shiftWhat

                                                         
    %             ,---.     |               o              
    %             |---.,---.|---.,---..    ,.,---.,---.    
    %             |   ||---'|   |,---| \  / ||   ||        
    %             `---'`---'`   '`---^  `'  ``---'`        
    %                  |         ,---.,---.              o     
    %             ,---.|---..   .|__. |__.     ,-.-.,---..,---.
    %             `---.|   ||   ||    |        | | |,---|||   |
    %             `---'`   '`---'`    `        ` ' '`---^``   '
    %                                                          
    case 'behavior'

            shuffle = behaviorbasedshuffle(shifts, spikes, beh, Opts);
            [shuffle, out] = concatonatelabelAndCache(shuffle, outfolder);

            beh.time = original_time;
        end

    case 'spikes'

end

if iscell(out.beh) && istable(out.beh{1})
    out.beh = util.table.icat(out.beh);
end
function measuretimeperiods(beh, groups
nG = groups.nGroups;
measure = table(nan(nG,1), nan(nG,1), nan(nG,1), 'VariableNames', ["start","stop","len"]);
for g = groups.uGroups'
    measure.start(g) = beh.time(find(groups.time.groups == g, 1, 'first'));
    measure.stop(g)  = beh.time(find(groups.time.groups == g, 1, 'last'));
end
measure.len = measure.stop - measure.start;

function [shifts] = calculateshifts(measure, Opts)

    % Calculate shifts
    if strcmp(Opt.shuffleunits, 'uniform')
        shifts = nan(Opt.shuffleCount, 1, groups.nGroups, 'single');
    elseif strcmp(Opt.shuffleunits, 'unitwise')
        shifts = nan(Opt.shuffleCount, height(spikes.cellTable), groups.nGroups, 'single');
    end

    nNeurons = height(spikes.cellTable);
    [S, N, G] = util.ndgrid.coord(shifts);
    if Opt.width == "whole"
        W = measure.len(G);
    else
        error("Not implemented")
    end

    switch Opt.shiftstatistic
        case 'uniform'
            shifts = W .* (rand(size(shifts)) - 0.5);
        case 'normal'
            shifts = W .* randn(size(shifts));
    end

function [out, outfolder] = prepareOuts(Opt)
% SET UP OUTPUTS
    
    outfolder = char([]);

    if ~isempty(Opt.cacheToDisk)
        switch Opt.cacheToDisk
        case 'matfile'
            out = coding.file.shufflematfile(Opt.cacheToDisk{:});
        case 'parquet'
            out = struct();
            outfolder = coding.file.parquetfolder(Opt.cacheToDisk{:});
        otherwise
            error("Bad method")
        end
    else
        out = struct();
    end
    out.Groups = groups;
    out.shuffleCount = Opt.shuffleCount;
    out.nNeurons = nNeurons;
    out.nGroups  = groups.nGroups;
    out.groupby = groupby;
    out.shifts = shifts;
    out.Opt = Opt;

function behaviorbasedshuffle(shift, spikes, beh, Opt)

        beh = util.table.castefficient(beh, 'negativeNan', true);
        original_time = beh.time;
        Opt.preallocationSize = min(Opt.shuffleCount, Opt.preallocationSize);
        if ismember('shuffle', fieldnames(out))
            util.matfile.rmsinglevar(out.Properties.Source, 'shuffle');
        end

        count = 0;
        for s = progress(1:Opt.preallocationSize:Opt.shuffleCount,...
                'Title', 'Shuffling behavior')

            endPoint = min(s+Opt.preallocationSize-1, Opt.shuffleCount);
            piece.shifts = shifts(s:endPoint,:,:);
            beh.time = original_time;
            %% -------------------------------------   %%
            %% THE MAGIC : where group-shuffle happens %%
            %% -------------------------------------   %%
            piece.newtimes = ...
                units.shuffle.helper.preallocateBehaviorShifts(piece.shifts,...
                beh, groups);
            %% ------------------------------------- %%
            %% ------------------------------------- %%
            clear shuffle

            % ------------------------------------
            % QUERY shuffle times from neural data
            % ------------------------------------
            SN = util.indicesMatrixForm([endPoint-s+1, nNeurons]);
            for sn = progress(SN', 'Title', 'Shifting cells')

                iShuff = sn(1);
                iNeuron = sn(2);

                beh.time = squeeze(piece.newtimes(iShuff, iNeuron, :));
                tmp = ...
                    units.atBehavior_singleCell(spikes.spikeTimes{iNeuron}, ...
                    beh, kws_atBehavior);
                if iscell(tmp)
                    shuffle(iShuff, iNeuron, :) =  tmp;
                else
                    shuffle{iShuff, iNeuron} =  tmp;
                end
            end
            % ------------------------------------
            
function concatonatelabelAndCache()

        % ------------------------------------
        % Concatonate and label and cache
        % ------------------------------------
        shuffle = nd.dimLabel(shuffle, 1:2, ["shuffle","neuron"], ...
            {s:endPoint, 1:nNeurons});
        shuffle = util.cell.icat(shuffle, 2);
        shuffle = shuffle{1};

        if ~isempty(Opt.cacheToDisk)
            switch lower(char(Opt.cacheMethod))
            case 'matfile'
                for shuff = progress(unique(shuffle.shuffle)',...
                        'Title', 'Storing shuffle')
                    thing = table2struct(shuffle(shuffle.shuffle==shuff, :),...
                        'ToScalar', true);
                    out.beh(shuff, 1) = thing;
                end
            case 'parquet'
                for shuff = progress(unique(shuffle.shuffle)',...
                        'Title', 'Storing shuffle')
                    parquetwrite(outfolder, shuffle(shuffle.shuffle==shuff, :));
                end
                out.beh = shuffle;
            end
        else
            out.beh = shuffle;
        end
        % ------------------------------------

