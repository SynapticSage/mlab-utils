function logicalIndex = minmax(values, minAndMax, varargin)
% util.constrain.minmax

ip = inputParser;
ip.addParameter('bounds', 'openclosed'); % openopen | {openclosed} | closedopen | closedclosed
ip.parse(varargin{:})
Opt = ip.Results;

if minAndMax(1) > minAndMax(2)
    error("Min and Max out of order")
end


if strcmpi(Opt.bounds, 'openclosed')
    logicalIndex = values >= minAndMax(1) & values < minAndMax(2);
else
    error("Option not implemented")
end

