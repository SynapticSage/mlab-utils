function res = cellfetch(cellinput, field, varargin)
% RYan's cleaned up version of cellfetch


ip = inputParser;
ip.addParameter('emptyMatchType', true);
ip.addParameter('asTable', true);
ip.addParameter('castType', []);
ip.addParameter('vectorize', true);
ip.addParameter('missingval', []);
ip.addParameter('dropmissing', false);
ip.parse(varargin{:})
Opt = ip.Results;


res = cellfetch(cellinput, field);
empty = cellfun(@isempty, res.values);

if Opt.dropmissing
    res.values(empty) = [];
    res.index(empty) = [];
    empty = [];
end

if Opt.emptyMatchType

    % Obtain the overall type
    overall_type = string(cellfun(@class, res.values, 'UniformOutput', false));
    overall_type = overall_type(overall_type~="double");
    if ~isempty(overall_type)
        overall_type = overall_type(1);
    else
        overall_type = "double";
    end

    % Obtain the empty fields
    res.values(empty) = cellfun(@(x) cast(x, overall_type), res.values(empty), 'uniformoutput', false);

end

if ~isempty(Opt.missingval)
    res.values(empty) = num2cell(repmat(Opt.missingval, size(res.values(empty))));
end

if Opt.vectorize
    if ischar(res.values{1})
        res.values = string(res.values);
    else
        res.values = cat(1, res.values{:});
    end
end
