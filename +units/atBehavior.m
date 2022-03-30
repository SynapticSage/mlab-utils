function [spikes, beh, dups] = atBehavior(beh, spikes, varargin)
%function spikes = atBehavior(beh, spikes)
%
%
% Inputs
% -------
% beh is a struct/table
%   of all relevent behavior properties per timee
%
% spikes is a struct
% of spike info from unit.getRateMatrix
%
% In all cases, spikes is a struct of the form
% from units.getSpikeMatrix()
%
% Optional args
% ------------
% to induce a shift in spike times,
% unit.atBehavior(beh, spikes, 'shiftSpikeTimes', 0.001); 
%
% % This queries behavior with spike times shifted forward a millisecond
%
%
% behFilter : filters out behavior that fails to match a criterion
%
%   you can really use this to condition on anything recorded in the behavior
%   table including speed.

ip = inputParser;
ip.KeepUnmatched = true; % See atBehavior_singleCell for shuffle instructions

% Overall format of the inputs
ip.addParameter('sparse', true);    % whether to expect sparse spike info or dense raster in spikes struct

% Overall format of the outputs
ip.addParameter('returnIndices', false);

% Essential matching algorithm
ip.addParameter('shift', 0);                      % Shift spike tines by how much
ip.addParameter('matchTimeTolerance', 1/20);      % tolerance for a spike time to match a behavior

% Processing speed
ip.addParameter('useGPU', false);
ip.addParameter('useParallel', false);

% Processing memory
ip.addParameter('pack', false);

% Format of tables/matrices
ip.addParameter('props', []);                     % List of vars to constrain the table to

% Table query
ip.addParameter('query', []);

% Beh variable type
ip.parse(varargin{:})
Opt = ip.Results;
dups = [];

if ~isstruct(spikes) && isstruct(beh)
    error("Spikes and Beh are flipped")
end

if isempty(Opt.shift)
    error("Ryan, your shifts are empty dumbass. Try 0 if you'd like to have no time shift");
end

if ~isempty(Opt.props)
    Opt.props = intersect(union(Opt.props, "time"), string(fieldnames(beh)));
    beh = beh(:, union("time", Opt.props));
end
if ~isempty(Opt.query)
    beh = util.table.query(beh, Opt.query);
end

if isstruct(beh)
    restoreStruct = true;
    beh = struct2table(beh);
else
    restoreStruct = false;
end

if istable(beh) && Opt.sparse % SPARSE SPIKE TIMES

    beh.time = double(beh.time);
    dups = util.getduplicates_logical(beh.time);
    beh = beh(~dups,:);

    nNeurons = numel(spikes.spikeTimes);
    spikes.beh = cell(1, nNeurons);
    for iCell = progress(1:nNeurons, 'Title', 'Finding behavior per neuron')

        Opt.annotateNeuron = [iCell, nNeurons];
        % PARALLEL VERSION OF SINGLECLEL
        if Opt.useParallel
            if iCell == 1; cluster = parcluster; end
            util.job.waitQueueSize(4, 20, cluster);
            jobs{iCell} = batch(@units.atBehavior_singleCell, 2, {spikes.spikeTimes{iCell}, beh, Opt});
        else
            % NON PARALLEL
            spikes.beh{iCell} = units.atBehavior_singleCell(spikes.spikeTimes{iCell}, beh, util.struct.update(Opt, ip.Unmatched));
        end
    end

    % PARALLEL VERSION OF SINGLECLEL: collect
    if Opt.useParallel
        for iCell = 1:numel(spikes.spikeTimes)
            [spikes.beh{iCell}, spikes.spikeTimes{iCell}] ...
                = fetchOutputs(jobs{iCell});
        end
        for iCell = 1:numel(spikes.spikeTimes)
            delete(jobs{iCell});
        end
    end
    % PARALLEL VERSION OF SINGLECLEL: end collect

    spikes.beh = spikes.beh(:); % Array spikes in the 1st dimension
    if any(cellfun(@numel, spikes.beh) == 0)
        warning('Empty tables afoot');
    end

    % If we have shifts, we neeed to convert the branched cell
    % into a cell with matrix dimensions, 1: neuron x 1: shift
    if iscell(spikes.beh)
        spikes.beh = cat(1, spikes.beh{:});
        % May have to use something like this if {:} doesn't work
        % -------------------------------------------------------
        % spikes.beh = util.cell.icat(spikes.beh, 1,...
        %     'fieldCombine', 'union', 'pack', Opt.pack);
    end


elseif isnumeric(beh) || ~Opt.sparse % DENSE RASTER

    times = beh;
    inds  = interp1(spike.time, 1:numel(spike.time), times, 'nearest');
    dups  = util.getduplicates_logical(inds);
    inds  = inds(~dups);
    beh   = beh(~dups, :);
    for field = ["data", "time"]
        spikes.(field) = spikes.(field)(inds,:);
    end

end

if restoreStruct
    error('Code not valid right now')
    for iCell = 1:numel(spikes.spikeTimes)
        spikes.beh{iCell} = table2struct(spikes.beh{iCell});
    end
end

spikes.shift = Opt.shift;

%% Cleaning steps
if Opt.useGPU
    spikes     = util.struct.GPUstruct2struct(spikes);
    spikes.beh = util.table.GPUtable2table(spikes.beh);
end

% Add missing cells
if util.struct.isfield(spikes.beh, 'neuron')
    spikes = units.clean.sparse.addMissingNeurons(spikes);
end


% Checksum : Check none of the data is still on the GPU
assert(~util.table.isGPUtable(spikes.beh), "Fuck! Your table item is on the GPU.")


if Opt.returnIndices
    spikes.behtype = "indices";
else
    spikes.behtype = "behavior";
end
