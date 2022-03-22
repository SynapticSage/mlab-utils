function answer = isGPUtable(tableItem)
% This function tests if an object is of GPU table type


if istable(tableItem)

    tableItem = table2struct(tableItem, 'ToScalar', true);
    isOnGPU = structfun(@(fielditem) isa(fielditem, 'gpuArray'), tableItem, "UniformOutput", true);

    answer =  any(isOnGPU, 'all');

elseif iscell(tableItem)

    % If any of the tables nested within the cell are GPU type,
    % we want an answer of TRUE
    answer = any(cellfun(@util.table.isGPUtable, tableItem), 'all');

else

    error("tableItem is an improper type!")

end
