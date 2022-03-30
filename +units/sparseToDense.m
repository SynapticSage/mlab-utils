function spikes = sparseToDense(spikes, varargin)
% Uses a sparse spike struct and a time
% range to generate a dense struct
%
% if no time range, takes the min and the
% max of that time.

ip = inputParser;
% --------------------------
% Basic epoch ranges and output formatting
% --------------------------
ip.addParameter('startTime', []); % start time of the dense matrix epochs
ip.addParameter('endTime',   []);   % end   time of the dense matrix epochs
ip.addParameter('binnedOutput', 'count');     % rate | {count}
ip.addParameter('returnOutput', 'annotated'); % {annotated} | matrix ,i f matrix then the output is merely the dense matrix. if annotated then the output is an annotated structure with a .data field
% --------------------------
% Densification method
% --------------------------
ip.addParameter('method', ''); % overlappingWindows|nonOverlappingWindows|instantaneous
ip.addParameter('samplingPeriod', 0.001);        % 1ms if user says nothing
ip.addParameter('nSamples', []);        % Overrides samplingPeriod ... number of elements one wants
ip.addParameter('window', [-0.0005, 0.0005]); % window when using method=overlappingWindow
ip.addParameter('interpMethod', 'linear'); % Valid only for the instanteous rate method
ip.addParameter('interpolateQuery', []); % 
% --------------------------
% Cleaning
% --------------------------
ip.addParameter('filterSpurious', 1);         % amount allowed per 1ms if user says nothing
ip.addParameter('gaussianFilter', {});        % Width for a gaussian filter; inpput to gausskernel function
ip.addParameter('removeInactiveCells', true); % 
% ----- How to process ------
ip.addParameter('chunkSize', 500);            % if sampling rate, how many times to process each iteration
% ----- Visualizations ------
ip.addParameter('ploton', false);             % plots dense firing rate data
ip.KeepUnmatched = true;
ip.parse(varargin{:})
Opt = ip.Results;

% how many cells?
nCells = numel(spikes.spikeTimes);

% if no passed in method, which to use?
if isempty(Opt.method)
    if isempty(Opt.samplingPeriod)
        Opt.method = 'overlappingWindows';
    else
        Opt.method = 'nonOverlappingWindows';
    end
end

%% --------------------------------------------
%% Fetch start and end times if they're missing
%% --------------------------------------------
if isempty(Opt.startTime)
    Opt.startTime = spikes.timePeriods(:,1);
end
if isempty(Opt.endTime)
    Opt.endTime   = spikes.timePeriods(:,2);
end
assert(numel(Opt.startTime) == numel(Opt.endTime));

disp('GETTING DENSE RATE MATRICES')
% ---------------------
% TIME BIN METHOD
% ---------------------
switch Opt.method
    case 'overlappingWindows'
        %
        % -------------
        % requirements
        % -------------
        % 

        disp('(Time bin mode)')
        [t_midpoints, t_startends] = units.time.overlapping([Opt.startTime, Opt.endTime], ...
            Opt.samplingPeriod, 'window', Opt.window)
        windowStarts = t_startends(1,:);
        windowStops = t_startends(2,:);

        p = ProgressBar(nCells, ...
            'Title', 'cells');
        nTimes = length(t_midpoints);
        spikeCountMatrix = zeros(nCells,nTimes);
        %'IsParallel',true);
        p.setup([],[],[]);
        cleanupFunction = onCleanup(@(x) ProgressBar.deleteAllTimers());
        for i = progress(1:nCells) % surrounding a 1:nCells with progress() adds a progress bar
            one_cell_spiking = spikes.spikeTimes{i};
            nSpikes = numel(one_cell_spiking);
            spikeCountSlice = zeros(1, nTimes);
            for t = progress(1:Opt.chunkSize:numel(spikes.spikeTimes{i}) ,'Title','SpikeChunks')
                spikeChunk = one_cell_spiking(t:min(t+Opt.chunkSize, nSpikes));
                spikeCountSlice = spikeCountSlice + ...
                    sum( spikeChunk' >= windowStarts & ...
                    spikeChunk' < windowStops);
            end
            spikeCountMatrix(i, :) = spikeCountSlice;
            p.step([], [], []);
        end
        spikeRateMatrix = spikeCountMatrix/Opt.samplingPeriod;

    case 'nonOverlappingWindows'
        % 
        % STANDARD WINDOW METHOD
        %
        % ------------
        % Requirements
        % ------------
        % 
        disp('(samprate method)')

        % Setup time matrices
        % -------------------
        [t_midpoints, t_startends]  = units.time.nonoverlapping(...
            [Opt.startTime, Opt.endTime], 'samplingPeriod', Opt.samplingPeriod);

        % Densify spikes
        % --------------
        spikeCountMatrix = zeros(nCells, length(t_startends)-1, 'single');
        spikeRateMatrix  = zeros(nCells, length(t_startends)-1, 'single');
        for i = progress(1:nCells)
            spike_count = histcounts(double(spikes.spikeTimes{i}),...
                t_startends);
            spikeCountMatrix(i,:) = spike_count;
            spikeRateMatrix(i,:)  = spike_count/Opt.samplingPeriod;
        end

    case 'instantaneous'
        %
        % Implements an instantaneous firing rate
        %

        % Get instantaneous rates
        ds_times = cell(1, nCells);
        rates    = cell(1, nCells);
        for iCell = 1:nCells
            ds = diff(spikes.spikeTimes{iCell});
            ds_times{iCell} = spikes.spikeTimes{iCell}(1:end-1) + ds;
            rates{iCell} = 1./ds;
        end

        % Now interpolate to our time coordinates
        [t_midpoints, t_startends] =...
            units.time.nonoverlapping([Opt.startTime, Opt.endTime], Opt.samplingPeriod);

        % Interpolate all rates to that grid of points
        for iCell = 1:nCells
            if isempty(ds_times{iCell})
                rates{iCell} = zeros(size(t_midpoints));
            else
                rates{iCell} = util.interp.interp1(...
                    ds_times{iCell}, rates{iCell}, t_midpoints, Opt.interpMethod);
            end
        end
        spikeRateMatrix  = cat(1, rates{:});
        spikeCountMatrix = spikeRateMatrix * mean(diff(t_midpoints));

    otherwise

        error("Bad method")

end

    if Opt.interpolateQuery
        % if this option is on, we interpolate to some queried points
        interp1 = @(x) util.interp.interp1(t_midpoints, x, Opt.interpolateQuery, Opt.interpMethod);
        spikeRateMatrix  = interp1(spikeRateMatrix);
        spikeCountMatrix = interp1(spikeCountMatrix);

    end

    % ---------------
    % Fitler spurious : BUG
    % ---------------
    if Opt.filterSpurious % if it violates 1khz, then rate limit?
        samplingPeriod = Opt.samplingPeriod;
        countLimit = (Opt.filterSpurious * (samplingPeriod/1e-3));
        spikeCountMatrix(spikeCountMatrix > countLimit) = 0;
    end

    % --------------------------
    % Gaussian filter the rates?
    % --------------------------
    if ~isempty(Opt.gaussianFilter)
        kernel = gausskernel(Opt.gaussianFilter{:});
        elements = 1:size(spikeRateMatrix,1);
        kws = {'UniformOutput', false};
        spikeRateMatrix = arrayfun(@(neuron) conv(spikeRateMatrix(neuron,:), kernel,'same'), elements, kws{:});
        spikeRateMatrix = cat(1,spikeRateMatrix{:});
        spikeCountMatrix = arrayfun(@(neuron) conv(spikeCountMatrix(neuron,:), kernel,'same'), elements , kws{:});
        spikeCountMatrix = cat(1, spikeCountMatrix{:});
    end

    if strcmpi(Opt.binnedOutput, 'rate')
        spikes.data       = single(spikeRateMatrix)';
    elseif strcmp(Opt.binnedOutput, 'count')
    spikes.data       = util.type.castefficient(spikeRateMatrix, 'negativeNan', 1)';
else
    error("Bad binnedOutput")
end

spikes.time       = t_midpoints(:);
spikes.binEdges   = t_startends(:);
spikes.samplingRate = Opt.samplingPeriod;
spikes.dt = Opt.samplingPeriod;
spikes.spikeCountMatrix = uint8(spikeCountMatrix);

if strcmpi(Opt.returnOutput, 'matrix')
    spikes = spikes.data;
end

if Opt.ploton
    fig('Firing rate checks')
    tiledlayout('flow'); 
    for i = progress(1:size(Spikes.data,2))
        nexttile; 
        histogram(Spikes.data(:,1)); 
    end
    set(findobj(gcf,'type','axes'),'ylim',[0,1000])
end
