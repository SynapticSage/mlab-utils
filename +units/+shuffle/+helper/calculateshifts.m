function [shifts] = calculateshifts(spikes, groups, measure, Opt)

disp("Calculating shifts")

% Calculate shifts
if strcmp(Opt.shuffleunits, 'uniform')
    shifts = nan(Opt.nShuffle, 1, groups.nGroups, 'single');
elseif strcmp(Opt.shuffleunits, 'unitwise')
    shifts = nan(Opt.nShuffle, height(spikes.cellTable), groups.nGroups, 'single');
end

[~, ~, G] = util.ndgrid.coord(shifts);
if Opt.width == "whole"
    W = measure.len(G);
else
    error("Not implemented")
end

switch Opt.shiftstatistic
    case 'uniform'
        shifts = W .* (rand(size(shifts)) - 0.5);
    case 'normal'
        shifts = W .* randn(size(shifts));
end


