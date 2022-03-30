function varargout = yield(shufflemethod, varpos, varkws)
% Yields a single shuffle given a shuffle method

    if iscell(varkws)
        varkws = util.struct.varargin2struct(varkws);
    end

    varkws.shuffleCount = 1;
    varkws = util.struct.struct2varargin(varkws);
    [out, group] = shufflemethod(varpos{:}, varkws{:});

    varargout{1} = out;
    varargout{2} = group;
