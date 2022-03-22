function T = struct2GPUstruct(T, varargin)
% Sets all of the struct elements into the GPU

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('cast', []);
ip.addParameter('recursive', false);
ip.parse(varargin{:})
Opt = ip.Results;

if ~isempty(Opt.cast)
    if iscell(Opt.cast)
        fun = @(x) gpuArray(x, Opt.cast{:})
    else
        fun = gpuArray(x, Opt.cast);
    end
else
    fun = @gpuArray;
end
if ~Opt.recursive
    T = nd.apply(T, "*", fun);
else
    T = nd.apply(T, "**", fun);
end
