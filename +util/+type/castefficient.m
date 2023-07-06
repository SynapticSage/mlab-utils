function X = castefficient(X, varargin)
% Finds the most space efficient way to rep a variable
%
%
% For doubles, can cast to single
%
% If it detects int, then it attempts to find the smallest int size that the
%  number would fit into.

ip = inputParser;
ip.addParameter('compressReals', false);
ip.addParameter('negativeNan',   false);
ip.addParameter('nancheck',      true);
ip.addParameter('minmaxOverride', []); 
ip.addParameter('verbose',       false, @islogical);
ip.KeepUnmatched = true;
ip.parse(varargin{:});
Opt = ip.Results;

if iscell(X)
    for i = 1:numel(X)
        X{i} = util.type.castefficient(X{i}, varargin{:});
    end
elseif istable(X)
    X = util.table.castefficient(X, varargin{:});
elseif isa(X, 'matlab.io.MatFile')
    fields = fieldnames(X);
    fields = setdiff(fields, {'Properties', 'Writable', 'Filename'});
    for i = 1:numel(fields)
        X.(fields{i}) = util.type.castefficient(X.(fields{i}), varargin{:});
    end
elseif isstruct(X) && ~isscalar(X)
    if Opt.verbose; disp("...iterating struct"); end
    for i = 1:numel(X)
        X(i) = util.type.castefficient(X(i), varargin{:});
    end
elseif isstruct(X)  && isscalar(X)
    fn = fieldnames(X);
    for i = 1:numel(fn)
        if Opt.verbose
            disp("...iterating struct field " + fn{i})
            fprintf("... old class: %s -> ", class(X.(fn{i})))
        end
        X.(fn{i}) = util.type.castefficient(X.(fn{i}), varargin{:});
        if Opt.verbose
            fprintf(" new class: %s\n", class(X.(fn{i})))
        end
    end
else
    if isnumeric(X)
        if Opt.negativeNan
            X(isnan(X)) = -1;
        end
        if Opt.nancheck
            nancheck = all(~isnan(X), 'all');
        else
            nancheck = true;
        end
        isInt = all(floor(X) == X, 'all');
        if isInt && nancheck

            if ~isempty(Opt.minmaxOverride)
                lower = Opt.minmaxOverride(1);
                upper = Opt.minmaxOverride(2);
            else
                lower = min(X);
                upper = max(X);
            end

            if all(lower >= intmin('uint8') & upper <= intmax('uint8'))
                X = uint8(X);
            elseif all(lower >= intmin('uint16') & upper <= intmax('uint16'))
                X = uint16(X);
            elseif all(lower >= intmin('uint32') & upper <= intmax('uint32'))
                X = uint32(X);
            elseif all(lower >= intmin('uint64') & upper <= intmax('uint64'))
                X = uint64(X);
            elseif all(lower >= intmin('int8') & upper <= intmax('int8'))
                X = int8(X);
            elseif all(lower >= intmin('int16') & upper <= intmax('int16'))
                X = int16(X);
            elseif all(lower >= intmin('int32') & upper <= intmax('int32'))
                X = int32(X);
            elseif all(lower >= intmin('int64') & upper <= intmax('int64'))
                X = int64(X);
            end
        elseif ~isInt && Opt.compressReals  && isa(X, 'double')
            X = single(X);
        end
    end
end
