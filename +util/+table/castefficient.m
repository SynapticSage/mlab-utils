function T = castefficient(T, varargin)
% Attempt to guess efficient types to cast for columns of T
% and cast those columsnt to msot space efficient types

ip = inputParser;
ip.addParameter('compressRealsExcept', {});
ip.KeepUnmatched = true; % unmatched params are fed to util.type.castefficient
ip.parse(varargin{:})
Opt = ip.Results;

if iscell(T)
    for i = 1:numel(T)
        T{i} = util.table.castefficient(T{i}, varargin{:});
    end
else
    for field = string(fieldnames(T)')
        if ismember(field, ["Properties", "Row", "Rows", "Variables"])
            continue
        end
        if ~ismember(field, Opt.compressRealsExcept)
            T.(field) = util.type.castefficient(T.(field), varargin{:});
        end
    end
end
