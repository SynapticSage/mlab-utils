function T= GPUstruct2struct(T, varargin)
% Gathers all struct elements from the GPU

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('cast', []);
ip.parse(varargin{:})
Opt = ip.Results;

if ~isempty(Opt.cast)
    if iscell(Opt.cast)
        T = structfun(@(x) gather(x, Opt.cast{:}), T, 'ToScalar', true, 'recurseCell', true);
    else
        T = structfun(@(x) gather(x, Opt.cast), T,    'ToScalar', true, 'recurseCell', true);
    end
else
    T = nd.apply(T, "**", @gather, 'recurseCell', true, 'ignoreEmpty', false);
end


