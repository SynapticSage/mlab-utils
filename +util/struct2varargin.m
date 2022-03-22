function V = struct2varargin(Opt)
% Converts an Option struct into varargin name-value cell

if isempty(Opt)
    V = {};
else
    if iscell(Opt) && numel(Opt) == 1
        Opt = Opt{1};
        assert(isstruct(Opt));
        return
    elseif isstruct(Opt)

    else
        error('Improper input');
    end

    fields = cellstr(fieldnames(Opt));
    values = struct2cell(Opt);
    fields = fields(:)';
    values = values(:)';

    V = [fields; values];
    V = V(:)';
end
