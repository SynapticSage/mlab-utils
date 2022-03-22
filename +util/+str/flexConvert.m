function x = flexConvert(x)

if iscell(x)
    x = cellfun(@(x) char(string(x)), x, 'UniformOutput', false);
    x = cellfun(@(x) [x(:)]', x, 'UniformOutput', false);
    x = string(x);
else
    error("not implemented")
end
