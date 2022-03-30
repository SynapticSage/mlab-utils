function tab = labeledSpiking(spikes, props, beh, task)
% Created a labeled tidy data structure for raw spiking events

task = task(:, ["day","epoch","start","end"]);
task = unique(task, 'rows');

tab = cell(numel(spikes.spikeTimes), 1);
for iCell = 1:numel(spikes.spikeTimes)
    time = spikes.spikeTimes{iCell};
    unit = repmat(spikes.cellTable(iCell,:).unit, numel(time), 1);
    spiketable = repmat(spikes.cellTable(iCell, :), numel(time), 1);
    spiketable.unit = unit(:);
    spiketable.time = time(:);
    % Add properties from behavior table?
    if ~isempty(props)
        for prop  = string(props(:))'
            inds = spikes.beh{iCell}.indices;
            nonzero = inds>0;
            x = nan(height(spiketable), 1);
            x(nonzero) = beh.(prop)(inds(nonzero)); 
            spiketable.(prop) = x;
        end
        spiketable.index = spikes.beh{iCell}.indices;
    end

    spiketable.epoch = nan(height(spiketable),1);
    for e = 1:height(task)
        inds = util.constrain.minmax(spiketable.time, [task(e,:).start, task(e,:).end]);
        spiketable.epoch(inds) = repmat(task.epoch(e), sum(inds), 1);
    end

    tab{iCell} = spiketable;
end

tab = util.cell.icat(tab);
tab = util.table.castefficient(tab);
