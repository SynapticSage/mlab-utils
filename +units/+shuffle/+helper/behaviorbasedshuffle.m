function out = behaviorbasedshuffle(out, shifts, groups, spikes, beh, Opt)

disp("Beginning behavior based shuffle")
nNeurons = height(spikes.cellTable);

% Ready input and output variables
beh = util.table.castefficient(beh, 'negativeNan', true);
original_time = beh.time;
Opt.preallocationSize = min(Opt.nShuffle, Opt.preallocationSize);

% Iterate through blocks of shufflse
prevShuff = -1;
singleShuffle = cell(1, nNeurons);
for s = progress(Opt.startShuffle:Opt.preallocationSize:Opt.endShuffle,...
        'Title', sprintf('Chunk(%d) of shuffles',...
                    Opt.preallocationSize))

    endPoint = min(s+Opt.preallocationSize-1, Opt.nShuffle);
    piece.shifts = shifts(s:endPoint,:,:);
    beh.time = original_time;

    %% THE MAGIC : where group-shuffle happens 
    %% -------------------------------------   
    piece.newtimes = ...
        units.shuffle.helper.preallocateBehaviorShifts(piece.shifts,...
        beh, groups);
    %% ------------------------------------- %%
    clear shuffle

    % QUERY shuffle times rom neural data
    % ------------------------------------
    SN = util.indicesMatrixForm([endPoint-s+1, nNeurons]);
    shuffle = cell(1, Opt.nShuffle);
    count = 0;
    pfExist = @(folder, file) exist(fullfile(folder, file), 'file')>0;
    for sn = progress(SN', 'Title', 'Shifting cells')
        count = count + 1;
        iShuff  = sn(1) + s - 1;
        iPreallocShuff  = sn(1);
        iNeuron = sn(2);

        % If we change to a new shuffle, store what we computed per cell
        notSkipProcessingPreviousShuff = ~Opt.skipShuffled || ~pfExist(Opt.outfolder, Opt.parquetfile(prevShuff));
        if (prevShuff ~= -1) && iShuff ~= prevShuff ...
            && notSkipProcessingPreviousShuff

            if istable(singleShuffle{1})
                tmp = util.cell.icat(singleShuffle, 2);
                assert(numel(tmp) == 1);
                clear singleShuffle
                singleShuffle = cell(1, nNeurons);
                tmp = tmp{1};
            else
            end
            [out, shuffle] = units.shuffle.helper.cache(out, tmp, shuffle, prevShuff, Opt);
        end

        skipProcessingCurrentShuffle = Opt.skipShuffled && pfExist(Opt.outfolder, Opt.parquetfile(iShuff));
        if skipProcessingCurrentShuffle
            disp("skipping")
            continue
        end

        beh.time = squeeze(piece.newtimes(iPreallocShuff, iNeuron, :));
        if ~util.isunique(beh.time)
            keyboard
        end
        Opt.kws_atBehavior.annotateNeuron = iNeuron;
        Opt.kws_atBehavior.maxNeuron      = nNeurons;
        tmp = ...
            units.atBehavior_singleCell(spikes.spikeTimes{iNeuron}, ...
            beh, Opt.kws_atBehavior);
        singleShuffle{iNeuron} = tmp;
        prevShuff = iShuff;
    end
end % END of shuffle loop

% Final expunge of shuffle contents
if ~isempty(singleShuffle) %happens when processing last is skipped
    tmp = util.cell.icat(singleShuffle, 2);
    clear singleShuffle 
    [out, shuffle] = units.shuffle.helper.cache(out, tmp{1}, shuffle, prevShuff, Opt);
end

% ------------------------------------
% Concatonate and label and cache
% ------------------------------------
if ~isempty(shuffle{1})
    shuffle = util.cell.icat(shuffle, 2);
    shuffle = shuffle{1};
    out.beh = shuffle;
end

