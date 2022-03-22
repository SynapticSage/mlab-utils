function result = fromStruct(result,  varargin)

ip = inputParser;
ip.addParameter('ignoreType',[]);
ip.addParameter('ignore',[]);
ip.addParameter('assertFields', []);
ip.parse(varargin{:})
Opt = ip.Results;

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

% Ignore type?
if ~isempty(Opt.ignoreType) && prod(size(result))
    types = arrayfun(@(x) string(class(table2array(result(1,x)))),...
                          1:width(result));
    result(:, ismember(types, Opt.ignoreType)) = [];
end
% Ignore field?
if ~isempty(Opt.ignore) && prod(size(result))
    result(:, ismember(result.Properties.VariableNames, Opt.ignore)) = [];
end

if ~isempty(Opt.assertFields)
    missingFields = ~ismember(string(Opt.assertFields), string(fieldnames(result)));
    if any(missingFields)
        missingFields = join(Opt.assertFields(missingFields), " ");
        error("Missing fields %S", missingFields);
    end
end
