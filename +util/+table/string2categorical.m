function T = string2categorical(T, varargin)

ip = inputParser;
ip.addParameter('recurseStruct',true); % If T is a struct, recurse?
ip.parse(varargin{:});
Opt = ip.Results;

if Opt.recurseStruct && isstruct(T)
    for field = string(fieldnames(T))'
        T.(field) = util.table.string2categorical(T.(field), Opt);
    end
elseif istable(T)
    for field = string(T.Properties.VariableNames)
        if isstring(T.(field))
            T.(field) = categorical(T.(field));
        end
    end
else
    error("Not a table or struct");
    T = [];
end
