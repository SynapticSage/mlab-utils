function empty = emptyLike(X, varargin)
% Returns a struct with the same size as X, but empty
%
% X can be an nd struct or an nd branched cell

if iscell(X)
    indices = ndBranch.indicesMatrixForm(X);
elseif isstruct(X)
    indices = nd.indicesMatrixForm(X);
end

ip = inputParser;
ip.addOptional('size', max(indices,[],1)) % size of the empty object
ip.addParameter('deep',true) %deep emptiness (matching types in a nested manner)
ip.parse(varargin{:});
opt = ip.Results;

empty = struct();
w=[];
for index = indices'

    if isstruct(X)
        I = num2cell(index);
        o = X(I{:});
    elseif iscell(X)
        o = ndBranch.get(X, index);
    end

    % Deep empty structure?
    if opt.deep
        oTypes = structfun(@class, o(1), 'UniformOutput', false);  % get classes
        thisEmpty = structfun(@(x)  [], o(1), 'UniformOutput', false);  % create an empty struct
        for field = string(fieldnames(thisEmpty)')
            if isequal(oTypes.(field), 'struct')
                thisEmpty.(field) = struct();
            elseif isequal(oTypes.(field), 'cell')
                thisEmpty.(field) = {};
            elseif isstring(o(1).(field))
                thisEmpty.(field) = string([]);
            elseif isequal(oTypes.(field),'table')
                thisEmpty.(field) = table();
            elseif isnumeric(o(1).(field)) || islogical(o(1).(field)) || ischar(o(1).(field))
                thisEmpty.(field) = cast([], oTypes.(field));
            else
                thisEmpty.(field) = [];
                warnmsg = string(sprintf('No rule for %s''s type => %s ... setting to []', field, oTypes.(field)));
                if numel(w)>0 || ~any(w == warnmsg)
                    w(end+1) = string(warning(warnmsg));
                end
            end
        end
        thisEmpty = repmat(thisEmpty, size(o));
    % Superficial empty structure?
    else
        thisEmpty = structfun(@(x)  [], o(1), 'UniformOutput', false);  % create an empty struct
    end

    % Build ideal empty structure
    for field = string(fieldnames(thisEmpty))'
       if ~isfield(empty, field)
           empty.(field) = thisEmpty.(field);
       elseif ~isequal(thisEmpty.(field), []) && isequal(empty.(field), [])
           empty.(field) = thisEmpty.(field);
       end
    end
end

if ~isempty(opt.size)
    if isscalar(opt.size)
        empty = repmat(empty, [opt.size, 1]);
    else
        empty = repmat(empty, opt.size);
    end
end
