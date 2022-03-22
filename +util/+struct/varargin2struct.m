function S = varargin2struct(varargin)

if ~isempty(varargin) && iscell(varargin{1})
    varargin = varargin{1};
end

S = struct();

if numel(varargin) > 1
    for f = 1:2:numel(varargin)
        S.(varargin{f}) = varargin{f+1};
    end
end