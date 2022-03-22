function T = GPUtable2table(T)
% % function T = GPUtable2table(T)
% Brings table back from the gpu

if iscell(T)
    T = cellfun(@util.table.GPUtable2table, T, 'UniformOutput', false);
else
    T = table2struct(T, 'ToScalar', true);
    T = nd.apply(T, "*", @gather, 'ignoreEmpty', false);
    T = struct2table(T);
    assert( ~util.table.isGPUtable(T), "Fuck");
end
