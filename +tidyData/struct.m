function result = struct(result)

if numel(result)>1
    error("This method is only for single struct. Try tidyData.structs");
end

result = structfun(@(x) x(:), result, 'UniformOutput', false);
fieldStrs = string(fieldnames(result));
result = struct2cell(result);
resultLen = cellfun(@numel, result);
resultFilter = resultLen == mode(resultLen);
result = result(resultFilter);
fieldStrs = fieldStrs(resultFilter);
result = table(result{:}, 'VariableNames', fieldStrs);