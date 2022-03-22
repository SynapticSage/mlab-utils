function T = table2GPUtable(T)
% % function T = table2GPUtable(T)
% Places the variables in the table into GPU

if iscell(T)
    T = cellfun(@util.table.table2GPUtable, T, 'UniformOutput', false);
else
    T = table2struct(T, 'ToScalar', true);
    T = nd.apply(T, "*", @gpuArray);
    T = struct2table(T);
end
