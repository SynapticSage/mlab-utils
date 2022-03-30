function shuffle = conditional_time(spikes, varargin)
% yields 1 shuffle at a time


ip = inputParser;
ip.addParameter('cacheToDisk', {}); % If cache to disk, this takes the parameters for coding.file.shufflefilename
ip.addParameter('shiftWhat', 'behavior'); % It's equibalent to shift behavior times repeatedly per cell or spike times per cell, but my estimate is that it's less memory intense for behavior
ip.addParameter('reset', false); % It's equibalent to shift behavior times repeatedly per cell or spike times per cell, but my estimate is that it's less memory intense for behavior

ip.addParameter('beh', []); 
ip.parse(varargin{:})
tmp = ip.Results;

persistent s groups shifts nNeurons Opt beh

if ~exist('s', 'var') || isempty(s) || tmp.reset
    s = 1;
    groups = cache.groups;
    shifts = cache.shifts;
    Opt = cache.Opts;
    Opt = util.struct.update(Opt, ip.Results);
    beh = Opt.beh;
    Opt = rmfield(Opt,'beh');
    beh = util.table.castefficient(beh, 'negativeNan', true);
    original_time = beh.time;
    Opt.preallocationSize = min(shuffleCount, Opt.preallocationSize);
    if ~isempty(Opt.cacheToDisk) 
        cache = coding.file.shufflematfile(Opt.cacheToDisk{:}, 'Writable', true);
        if ismember('shuffle', fieldnames(cache))
            util.matfile.rmsinglevar(cache.Properties.Source, 'shuffle');
        end
    end
    if ~isempty(Opt.prop)
        Opt.prop = union("time", string(Opt.prop));
        Opt.prop = union(groupby, string(Opt.prop));
        beh = beh(:, Opt.prop);
    end
    if Opt.dropGroupby && ismember(groupby, beh.Properties.VariableNames)
        beh(:, groupby) = [];
    end
else
    s = s+1;
end

switch Opt.shiftWhat

% BEHAVIOR BASED SHUFFLE (but same effect as shuffling spikes)
case 'behavior'

    piece.shifts = shifts(s,:,:);
    beh.time = original_time;
    piece.newtimes = ...
        units.shuffle.helper.preallocateBehaviorShifts(piece.shifts, beh, groups);

    % Now let's grab our actual shuffle
    SN = util.indicesMatrixForm([1, nNeurons]);
    clear shuffle
    for sn = progress(SN', 'Title', 'Shifting cells')

        beh.time = squeeze(piece.newtimes(sn(1), sn(2), :));
        shuffle{sn(1), sn(2)} = ...
            units.atBehavior_singleCell(spikes.spikeTimes{sn(2)}, ...
            beh, ip.Unmatched);
    end
    shuffle = nd.dimLabel(shuffle, 1:2, ["shuffle","neuron"], ...
        {s, 1:nNeurons});
    shuffle = util.cell.icat(shuffle, 2);
    shuffle = shuffle{1};

    if ~isempty(Opt.cacheToDisk)
        for shuff = progress(unique(shuffle.shuffle)', 'Title', 'Writing to file')
            thing = table2struct(shuffle(shuffle.shuffle==shuff, :),...
                'ToScalar', true);
            cache.shuffle(shuff, 1) = thing;
        end
    end

    % SPIKES BASED SHUFFLE
    case 'spikes'
end

if s == shuffleCount
    clear s % reset when yield finishes
    clear beh
end
