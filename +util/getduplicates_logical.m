function [dups] = getduplicates_logical(x)

dups = util.getduplicates(x);
dups = ismember(1:numel(x), dups);
