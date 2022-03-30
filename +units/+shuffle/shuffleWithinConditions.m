function [out, groups] = shuffleWithinConditions(beh, spikes, groupby, varargin)
% Circularly shuffles within times per some conditioned group
%
%
% General shuffle method that caches the shuffles for later use....
%
%
% Used in...
% (1) Sarel 2017 and Dotson 2021 each requires circular spike time shuffles
% within trials. Doable by setting groupby to your relevent trial var name in
% the behavior table.
%
% -----
% Notes
% -----

% --------------------------------------------------------------
%                                              
%                     ,---.     |    o          
%                    |   |,---.|--- .,---.,---.
%                    |   ||   ||    ||   ||   |
%                    `---'|---'`---'``---'`   '
%                         |                    
% --------------------------------------------------------------
ip = units.shuffle.inputParser;
ip.parse(varargin{:})
Opt = ip.Results;
% Post-process
Opt.shuffleunits   = string(Opt.shuffleunits);
Opt.shiftstatistic = char(Opt.shiftstatistic);
Opt.cacheMethod = char(lower(Opt.cacheMethod));
if isempty(Opt.endShuffle)
    Opt.endShuffle = Opt.nShuffle;
end
Opt.shufflename = sprintf('shuffleWithinConditions=[%s]', ...
    join(groupby, "-"));
Opt.shufflename = string(Opt.shufflename);

% Behavior and single cell
if ~isempty(Opt.props)
    Opt.props = union("time", string(Opt.props));
    Opt.props = union(groupby, string(Opt.props));
    beh = beh(:, Opt.props);
end
% ATBEHAVIOR-SINGLECELL
% UNMATCHED PARAMS --> go to units.atBehavior_singleCell.m
Opt.kws_atBehavior = ip.Unmatched;
Opt.kws_atBehavior.maxNeuron = numel(spikes.spikeTimes);
if ~isfield(Opt.query, 'query')
    warning("You're about to emark on an un time filtered shuffle!")
end
Opt.groupby = groupby; % add the groupby list to options (so that downstream functiosn can see this, e.g. save functiosn for annotating saved data with waht we grouped by)
    

                                    
%----------------------------------------
%                     ,-.-.     o     
%                     | | |,---..,---.
%                     | | |,---|||   |
%                     ` ' '`---^``   '
%----------------------------------------
% Create set of shuffle times
%----------------------------------------
% Apply any filtration
if ~isempty(Opt.query)
    disp("Filtering with " + Opt.query);
    beh = util.table.query(beh, Opt.query);
end
% S x G x 1 if uniform or S x G x N if unit-based
if isempty(Opt.groups)
    disp("Finding groups")
    groups = util.table.findgroups(beh, groupby);
else
    groups = Opt.groups;
end
if Opt.dropGroupby
    beh(:, groupby) = [];
end

checksum = all(ismember(unique(diff(groups.time.groups(groups.time.groups~=-1))), [0,1]));
assert(checksum, 'Non-contiguous regions in your conditionals!')

measure = units.shuffle.helper.measuretimeperiods(beh, groups);
shifts = units.shuffle.helper.calculateshifts(spikes, groups, measure, Opt);

% Prepare the output structure and document our settings
[out, Opt] = units.shuffle.helper.prepareOuts(spikes, groupby, shifts, groups,  Opt);
% -------
% Shuffle
% -------
switch Opt.shiftWhat
    case 'behavior'
        % if matfile cache, then input(out) gets filed under out.shuffle,
        % i.e., out.shuffle = out, on the output end
        %
        % potentially confusing, I must admit
        out = units.shuffle.helper.behaviorbasedshuffle(out, shifts, groups, spikes, beh, Opt);
    case 'spikes'
end

if isfield(out, 'beh') && iscell(out.beh) && istable(out.beh{1})
    out.beh = util.table.icat(out.beh);
end

