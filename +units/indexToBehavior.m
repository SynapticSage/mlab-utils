function val = indexToBehavior(index, beh, varargin)
% if spikes has a behavior table that contains indices into the full behavior
% table for the spikeTimes, then this funciton translates that into a table
% of behavior. It indexes into the full behavior table.

ip = inputParser;
ip.addParameter('good_shift_indices', []); % optional constraint on useed indices
ip.parse(varargin{:})
Opt = ip.Results;

if isempty(Opt.good_shift_indices)
    Opt.good_shift_indices = true(height(index),1);
end

% Pull data from our shuffle index structure
Opt.good_shift_indices = find(Opt.good_shift_indices & index.indices > 0); % find somehow speeds up table type
indices_into_behavior_data = index.indices(Opt.good_shift_indices);
neuron_labels = index.neuron(Opt.good_shift_indices);
% Use those to index out behavior at spike times and label those times
% for corresponding neurons
val = beh(indices_into_behavior_data, :);
val.neuron = neuron_labels;
