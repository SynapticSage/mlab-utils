function T = cast(T, classType, varargin)
% function cast(T, classType, varargin)
% Executes a cast operation on each table entry or a set of fields

ip = inputParser;
ip.addParameter('fields', []);
ip.parse(varargin{:})
Opt = ip.Results;

if iscell(T)
    T = cellfun(@(x)util.table.cast(x, classType, varargin{:}), T, 'UniformOutput', false);
else
    T = table2struct(T, 'ToScalar', true);


    if isempty(Opt.fields) && (isscalar(classType) || ischar(classType))
        T = structfun(@(x) cast(x, classType), T, 'UniformOutput', false);
    else
        error("Not implemented")
    end

    T = struct2table(T);
end
