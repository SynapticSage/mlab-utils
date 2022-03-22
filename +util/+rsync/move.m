function [status, result] = move(source, destination, varagin)
% interface to rsync from matlab

if length(destination) > 1
    error("Only 1 destination, brah.")
end

varagin = string(varagin);
command = ["rsync", varagin, source, destination]
command = join(command, " ");

[status, result] = system(command);
