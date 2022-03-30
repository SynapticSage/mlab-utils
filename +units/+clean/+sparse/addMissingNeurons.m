function spikes = addMissingNeurons(spikes)
% function spikes = addMissingNeurons(spikes)
% Add missing neurons back to spikes.beh sparse table inside a spikes structure

if iscell(spikes.spikeTimes)
    neurons = 1:numel(spikes.spikeTimes);
else
    neurons = 1:size(spikes.spikeTimes,2);
end

if iscell(spikes.beh)
    existingneurons = cellfun(@(x) x.neuron, spikes.beh, 'UniformOutput', false);
    existingneurons = cat(1, existingneurons{:});
    newtab = spikes.beh{1}(1,:);
else
    existingneurons = spikes.beh.neuron;
    newtab          = spikes.beh(1,:);
end

ismissing = setdiff(neurons, existingneurons);

% Append missing entries with nan data
if ~isempty(ismissing)
    newtab(:,:) = repmat({nan}, size(newtab));
    newtab = repmat(newtab, numel(ismissing), 1);
    newtab.neuron = ismissing(:);
    if iscell(spikes.beh)
        for i = 1:numel(spikes.beh)
            spikes.beh{i} = [spikes.beh{i}; newtab];
        end
    else
        spikes.beh = [spikes.beh; newtab];
    end
end
