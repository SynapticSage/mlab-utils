function [status, result] = citmove(source, destination, varagin)
% Moves to citadel

destination = "citadel:" + destination;
[status, result] = util.rsync.move(source, destination, varagin{:});
