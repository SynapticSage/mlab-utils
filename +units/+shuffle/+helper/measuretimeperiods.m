function measure = measuretimeperiods(beh, groups)
% Obtains the start and stop periods

disp("Measuring time periods")

nG = groups.nGroups;
measure = table(nan(nG,1), nan(nG,1), nan(nG,1),...
    'VariableNames', ["start","stop","len"]);

for g = groups.uGroups'
    measure.start(g) = beh.time(find(groups.time.groups == g, 1, 'first'));
    measure.stop(g)  = beh.time(find(groups.time.groups == g, 1, 'last'));
end
measure.len = measure.stop - measure.start;

