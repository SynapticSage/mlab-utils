function [Spikes, timesSpiking] = getRateMatrix(animal, day, varargin)
% getRateMatrix
%
% Input
% -----
% animal: name of the animal
%
% day : day of recording
%
% Output
% -----
% spikes struct

ip = inputParser;
% ----- Data source --------
ip.addParameter('unit', 'spikes');            % datatype used for the point process
ip.addParameter('taskFilter', '');            % which epochs?
ip.addParameter('cellFilter', '');            % which cells?
ip.addParameter('spikes', []);             % pass the spike data to use here, so do not have to reload in RAM
% ----- Data shape ---------
ip.addParameter('dense', false);               % Whether to get the dense matrix or just keep only the sparse spike times
% ----- Cleaning option -------
ip.addParameter('constrainTimePeriodToSpiking', false);
ip.addParameter('removeInactiveCells', false);
ip.KeepUnmatched = true;
ip.parse(varargin{:});
Opt = ip.Results;
Opt.taskFilter = char(Opt.taskFilter);

switch Opt.unit
    case 'spikes'
        infoDatatype = "cellinfo";
    case 'multiunit'
        infoDatatype = "multiinfo";
    otherwise
        error("uncorecognized unit type");
end
if ~ndbFile.exist(animal, infoDatatype + "Table")
    coding.table.create(animal, infoDatatype);
end
infoDatatype = infoDatatype + "Table";
cellinfo = ndb.load(animal, infoDatatype);
indices = [cellinfo.day, cellinfo.epoch, cellinfo.tetrode, cellinfo.cell]; % day epoch tet cell

task = ndb.load(animal, 'task');
goodEpochs         = true(size(indices,1),1);
goodEpochs_source2 = true(size(indices,1),1);
if Opt.taskFilter
    taskIndices = evaluatefilter(task, Opt.taskFilter);
    goodEpochs = ismember(indices(:,1:2), taskIndices, 'rows');
end
if ~isempty(day)
    goodEpochs_source2 = ismember(indices(:,1:length(day)), day(:)', 'rows');
end
indices = indices(goodEpochs & goodEpochs_source2, :);

% get epoch start and end times
startendtimes = [];
for dayepoch = unique(indices(:,1:2), 'rows')'
    t = ndb.get(task, dayepoch);
    startendtimes = [startendtimes; ...
                     t.starttime, t.endtime];
end
if Opt.constrainTimePeriodToSpiking
    % This section would constrain those start end times of the epochs to minimally at the first spike and end maximally at the last spike
    minTimes = cellfun(@(x) min(x(:),[],'all'), timesSpiking, 'UniformOutput', false);
    minTimes = cat(0, minTimes{:});
    maxTimes = cellfun(@(x) max(x(:),[],'all'), timesSpiking, 'UniformOutput', false);
    maxTimes = cat(1, maxTimes{:});
    error("Not implemented yet!")
end

%------------------------------------------------------------------
% Fetch all of the spiking data from the filter framework format
%------------------------------------------------------------------
disp('Finding unique cells and storing spike times');
if ~isempty(Opt.spikes)
    spikes = ndb.toNd(Opt.spikes);
else
    spikes = ndb.load(animal, Opt.unit, 'ind', day, 'asNd', true);
end
cell_index = [];
areaPerNeuron = [];
cell_table = table();
timesSpiking = {};
inds_spikes = nd.indicesMatrixForm(spikes);
indices = intersect(inds_spikes, indices, 'rows'); % intersect task constrained cellinfo indices with actual indices of the spikes structure
emptyloc = 0; 
locs=0;
for ind = progress(indices')
    ind = num2cell(ind);
    [day, epoch, tetrode, neuron] = deal(ind{:});
    neuronTetEpoch_details = coding.table.summarize(cellinfo, [ind{:}]);
    neuronTetEpoch         = nd.get(spikes, [ind{:}]);
    %if any(ismember(fieldnames(neuronTetEpoch_details), 'area'))
    %    disp("found area")
    %end
    
    if ~isempty(neuronTetEpoch) && ~isfield(neuronTetEpoch, 'area')
        %warning("Area for %d %d %d %d not present", day, epoch, tetrode, neuron);
    end
    if ~isempty(neuronTetEpoch_details) ...
            && any(ismember(fieldnames(neuronTetEpoch_details), 'area'))...
            && ~isempty(neuronTetEpoch) ...
            && isfield(neuronTetEpoch,'data')...

        locs = locs + 1;
        ind = cat(2,ind{:});
        if any(size(neuronTetEpoch.data)==0)
            emptyloc = emptyloc + 1;
            warning("Empty location at " + join(string(ind), "-"));
            continue
        end

        % Continually update unique index list
        neurontet = [tetrode, neuron];
        cell_index(end+1,:) = neurontet;
        cell_index          = unique(cell_index, "rows", "stable");

        % Add data according to where the cell is on this list
        cell_match = ismember(cell_index, neurontet, 'rows');
        assert(sum(cell_match) == 1)
        i = find(cell_match);
        areaPerNeuron(i) = string(neuronTetEpoch_details.area);
        if numel(timesSpiking) < i
            timesSpiking{i}  = [(neuronTetEpoch.data(:,1))'];
        else
            timesSpiking{i}  = [timesSpiking{i}, (neuronTetEpoch.data(:,1))'];
        end
        cell_table(i,:) = coding.table.summarize(cellinfo, [day -1 tetrode neuron]);

    end
end

% -----------------------
% Checksum the cell count
% -----------------------
num_cells = size(cell_index,1);
assert(num_cells == height(cell_table))
if num_cells == 0
    error("No cells");
end
disp("Num cells")
disp(num_cells)
disp("Percent empty locations")
disp(emptyloc/locs);

%--------------------------------
% Remove cells lacking activity
%--------------------------------
if Opt.removeInactiveCells
    disp("Removing inactive cells")
    activeCells = ~all(spikeCountMatrix == 0,2);
    if ~any(activeCells); error("Fuck"); end
    spikeRateMatrix = spikeRateMatrix(activeCells,:);
    spikeCountMatrix = spikeCountMatrix(activeCells,:);
    cell_index = cell_index(activeCells,:);
    areaPerNeuron = areaPerNeuron(activeCells);
    cell_table = cell_index(activeCells,:);
    timesSpiking = timesSpiking(activeCells);
end

% ----------
% Struct out
% ----------
Spikes.spikeTimes = timesSpiking; % actual sparse spike times
Spikes.areas      = areaPerNeuron; % area of each cell (also in the property table)
Spikes.cellIndex = cell_index; % index of each cell in filter framework
Spikes.cellTable = cell_table; % table with properties of each cell
Spikes.timePeriods = startendtimes; % the time periods our data lives in (e.g., epochs)
Spikes.cellTable.unit = (1:height(Spikes.cellTable))';
Spikes.cellTable.unitoftet = Spikes.cellTable.cell;
Spikes.cellTable.cell = [];

if Opt.dense
    spikesData.type    = "rate";
else
    spikesData.type    = "spiketime";
end

if Opt.dense
    Spikes = units.sparseToDense(Spikes, ip.Unmatched);
end

% ------------------------------
% Filter cells by characterisics
% ------------------------------
% (Could be faster to move this section earlier)
if ~isempty(Opt.cellFilter)
    [Spikes.cellTable, ~, inds] = util.table.query(Spikes.cellTable, Opt.cellFilter);
    Spikes.spikeTimes           = Spikes.spikeTimes(inds);
    Spikes.areas                = Spikes.areas(inds);
    Spikes.cellIndex            = Spikes.cellIndex(inds,:);
end

