function [markData, timesSpiking] = getMarkMatrix(animal, day, varargin)
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
% spikeData struct

ip = inputParser;
ip.addParameter('timebinSize', 1/1500);        % 1500hz if user says nothing
ip.addParameter('filterSpurious', 1);         % amount allowed per 1ms if user says nothing
ip.addParameter('unit', 'marks');             % datatype used for the point process
ip.addParameter('timefield', 'times');        % datatype used for the point process
ip.addParameter('markfield', 'data');         % datatype used for the point process
ip.addParameter('markcols', ':');             % datatype used for the point process
ip.addParameter('minAmpMarks', 4);             % datatype used for the point process
ip.addParameter('minClusterMarks', 1);             % datatype used for the point process
ip.addParameter('samplingRate', []);
ip.addParameter('chunkSize', 500);            % if sampling rate, how many times to process each iteration
ip.addParameter('taskFilter', '');            % if sampling rate, how many times to process each iteration
ip.addParameter('removeInactiveCells', true); % if sampling rate, how many times to process each iteration
ip.addParameter('markData', []);             % pass the spike data to use here, so do not have to reload in RAM
ip.addParameter('ploton', false);             % if sampling rate, how many times to process each iteration
ip.addParameter('class', 'single');           % if sampling rate, how many times to process each iteration
ip.addParameter('voltageFactor', 0.195);           % if sampling rate, how many times to process each iteration
ip.parse(varargin{:})
Opt = ip.Results;
Opt.taskFilter = char(Opt.taskFilter);

if ~isempty(Opt.markData)
    spikes = ndb.toNd(Opt.markData);
else
    spikes = ndb.load(animal, Opt.unit, 'ind', day);
end

indices = ndb.indicesMatrixForm(spikes); % day epoch tet cell
spikes = ndb.toNd(spikes);
tetinfo = ndb.load(animal, 'tetinfo', 'ind', day);

    task = ndb.load(animal, 'task');
if Opt.taskFilter
    taskIndices = evaluatefilter(task, Opt.taskFilter);
    goodEpochs = ismember(indices(:,1:2), taskIndices, 'rows');
    indices = indices(goodEpochs, :);
    % get epoch start and end times
end
disp('Indices to process')
disp('------------------')
startendtimes = [];
for dayepoch = unique(indices(:,1:2), 'rows')'
    t = ndb.get(task, dayepoch);
    startendtimes = [startendtimes; ...
                     t.starttime, t.endtime];
end

%------------------------------------------------------------------
disp('Finding unique cells and storing spike times and mark values');
cell_index = [];
areaPerTetrode = string([]);
uTetrodes = unique(indices(:,3));
nTets    = numel(uTetrodes);
timesSpiking = cell(1, nTets);
markValues   = cell(1, nTets);
for ind = progress(indices')

    ind = num2cell(ind);

    [day, epoch, tetrode] = deal(ind{:});
    neuronTetEpoch_details        = ndb.get(tetinfo, [ind{:}]);
    neuronTetEpoch                = nd.get(spikes, [ind{:}]);

    % If it has data, let's add that cell
    if ~isempty(neuronTetEpoch_details) ...
            && ~isempty(neuronTetEpoch) ...
            && isfield(neuronTetEpoch,'data')...
            && ~isempty(neuronTetEpoch.data)

        i = find(tetrode == uTetrodes);

        if ~isfield(neuronTetEpoch_details, "area")
            continue
        end
        areaPerTetrode(i) = string(neuronTetEpoch_details.area)
        tetrodePerUnit(i) = tetrode;
        if numel(timesSpiking) < i || numel(timesSpiking{i}) == 0
            timesSpiking{i} = [(neuronTetEpoch.(Opt.timefield)(:,1))'];
            markValues{i}   = [(neuronTetEpoch.(Opt.markfield)(:,Opt.markcols))'];
        else
            timesSpiking{i} = [timesSpiking{i}, (neuronTetEpoch.(Opt.timefield)(:,1))'];
            markValues{i}   = [markValues{i}, (neuronTetEpoch.(Opt.markfield)(:,Opt.markcols))'];
        end
    end
end

minTimes = cellfun(@(x) min(x(:),[],'all'), timesSpiking, 'UniformOutput', false);
minTimes = cat(1, minTimes{:});
maxTimes = cellfun(@(x) max(x(:),[],'all'), timesSpiking, 'UniformOutput', false);
maxTimes = cat(1, maxTimes{:});

if nTets == 0
    error("No tetrodes");
end

% Check if mark sizes are okay
% ----------------------------
nMarks = cellfun(@(x) size(x,1), markValues);
nTheoreticalMarks = Opt.minAmpMarks + Opt.minClusterMarks;
for tet = 1:nTets
    if nMarks(tet) ~= 0 && nMarks(tet) < nTheoreticalMarks
        % In this case, we assume that we have fewer marks than
        % required because some of the tetrodes have dead channels
        newData = zeros(nTheoreticalMarks, size(markValues{tet},2));
        channelCount = size(markValues{tet}, 1);
        nCurrMark =  channelCount - Opt.minClusterMarks;
        newData(1:nCurrMark, :) = markValues{tet}(1:nCurrMark, :);
        newData(end-Opt.minClusterMarks+1: end, :) = markValues{tet}(end-Opt.minClusterMarks+1, :);
        markValues{tet} = newData;
        %[lQ, uQ] = quantile(channelCount, newData(1:Opt.quantile));
    end
end

%% Generate spike count/rate matrices
%% ----------------------------------
disp('Generating matrix');
start_time = min(startendtimes(:,1));
end_time   = max(startendtimes(:,2));

%% SAMPLING RATE METHOD?
if ~isempty(Opt.samplingRate) 
    
    samplingPeriod  = 1/Opt.samplingRate;
    timeBinStartEnd = arrayfun(@(i) startendtimes(i,1):samplingPeriod:startendtimes(i,2), 1:size(startendtimes, 1), 'UniformOutput', false);
    timeBinStartEnd = cat(1, timeBinStartEnd{:});
    nTimes          = length(timeBinStartEnd);

    spikeCountMatrix = zeros(nTets, nTimes, Opt.class);
    markTensor       = zeros(nTets, nMarks, nTimes, Opt.class);
    windowStarts = (timeBinStartEnd - Opt.timebinSize/2);
    windowStops =  (timeBinStartEnd + Opt.timebinSize/2);

    p = ProgressBar(num_cells, ...
        'Title', 'cells');
    p.setup([],[],[]);
    cleanupFunction = onCleanup(@(x) ProgressBar.deleteAllTimers());
    for i = progress(1:num_cells) % surrounding a 1:num_cells with progress() adds a progress bar
        one_cell_spiking = timesSpiking{i};
        nSpikes = numel(one_cell_spiking);
        spikeCountSlice = zeros(1, nTimes);
        for t = progress(1:Opt.chunkSize:numel(timesSpiking{i}) ,'Title','SpikeChunks')

            %
            spikeChunk = one_cell_spiking(t:min(t+Opt.chunkSize, nSpikes));
            markChunk  = one_cell_marks(t:min(t+Opt.chunkSize, nSpikes), :);

            %
            events     = spikeChunk' >= windowStarts & spikeChunk' < windowStops;

            % 
            [I, G] = find(events); 
            II = [II; I+t];
            II = [II; I+t];
            
            % 
            spikeCountSlice = spikeCountSlice + sum(events);
            markSlice       = markSlice + one_cell_marks(events);

        end
        marks = splitapply(@(x) mean(markChunk(x, :)), I, G);
        spikeCountMatrix(i, :) = spikeCountSlice;
        p.step([], [], []);
    end
    spikeRateMatrix = spikeCountMatrix/Opt.timebinSize;
    
%% STANDARD WINDOW METHOD?
else % standard option, just window size alone

    if isa(start_time,'single')
        Opt.timebinSize = single(Opt.timebinSize);
    end
    timeBinStartEnd = [];
    for epoch = 1:size(startendtimes,1)
        timeBinStartEnd = [timeBinStartEnd, startendtimes(epoch,1):Opt.timebinSize:startendtimes(epoch,2)];
    end
    timeBinMidPoints = [timeBinStartEnd(1:end-1)', timeBinStartEnd(2:end)'];
    timeBinMidPoints = mean(timeBinMidPoints,2)';
    if all(timeBinMidPoints==0), 
        error('Fuck'); 
    end
    if Opt.ploton
       figure;plot(timeBinMidPoints)
       hline(min(minTimes));
       hline(max(maxTimes));
    end

    nMarks = cellfun(@(x) size(x,1), markValues, 'UniformOutput', true);
    nMarks = nMarks(nMarks ~= 0);
    nMarks = min(nMarks);
    
    spikeCountMatrix = zeros(nTets, length(timeBinStartEnd)-1, Opt.class);
    markTensor       = zeros(nTets, length(timeBinStartEnd)-1, nMarks, Opt.class);

    for i = progress(1:nTets, 'Title', 'Collecting mark tensor')
        [spike_count, ~, bin] = histcounts(double(timesSpiking{i}), timeBinStartEnd); % obtain how many spikes per bin and bin assignment of each time event
        spikeCountMatrix(i,:) = spike_count;                                 % Spike count used for ground process
        if isempty(timesSpiking{i});
            continue
        end
        if all(spike_count <= 1) % One mark per bin?
            filt = bin > 0;
            bin = bin(filt);
            markValues{i}         = markValues{i}(:, filt);
            markTensor(i, bin, :) = markValues{i}(1:nMarks,:)';
        else % Sometimes more than one per bin?
            disp("Many marks per bin in " + num2str(i) + "th tet");
            [u, ia, ic] = unique(bin, 'stable');                                 % Now we need to identify indices into unique bins
            u = int64(u);                                                        % which have to be integer
            result = splitapply(@(x) mean(x,1), markValues{i}(1:nMarks,:)', ic); % And we feed that to split apply to split by those labels and average the marks in each window - if you use a high enough sampling rate, no more than one per bin
            filt = u <= 0;                                                       % Remove the zero bin - elements who do not belong in any bin
            u(filt) = [];                                                        % Delete those
            result(filt, :) = [];                                                % Delete those
            markTensor(i, u, :) = result;                                        % And store the result
        end
        %spikeRateMatrix(i,:)  = spike_count/Opt.timebinSize;
        %[sum(spike_count), numel(timesSpiking{i}), min(timeBinStartEnd), min(timesSpiking{i}), max(timeBinStartEnd), max(timesSpiking{i})]
    end

    if Opt.ploton
        figure;imagesc(spikeCountMatrix'); set(gca,'clim',[0,1])
    end

end

% Augment with session/epoch information?
% ---------------------------------------

% Fitler spurious : BUG
% ---------------
badtetrodes = find(all(markTensor==0, 2:3));
markTensor(badtetrodes,:,:) = [];
tetrodePerUnit(tetrodePerUnit==0) =[];

% Struct out
% ----------
markData.spikes     = spikeCountMatrix;
markData.marks      = markTensor;
markData.time       = timeBinMidPoints(:);
markData.binEdges   = timeBinStartEnd(:);
markData.areas      = areaPerTetrode;
markData.tetrodePerUnit = tetrodePerUnit;
