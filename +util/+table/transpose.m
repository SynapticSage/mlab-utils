function T = transpose(T)

RowNames = T.Properties.RowNames;
if isempty(RowNames) && height(T) == 1
    RowNames = {'index'};
end
VariableNames = T.Properties.VariableNames;
T = table(table2array(T)', 'RowNames', VariableNames, 'VariableNames', RowNames);
