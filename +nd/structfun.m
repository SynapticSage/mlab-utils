function T = structfun(S, dim, varargin)
% Major limitation: any averaged field must be equal in dimension, even if
% that dimensions match for elements in the averaged dimension. Could
% resolve by looping slices of S in the appropriate dimension.

ip = inputParser;
ip.addParameter('squeeze',true)
ip.addParameter('basedim', 2)
ip.addParameter('funargs', {});
ip.addParameter('funargs_dimPosition', 1);
ip.addParameter('fun', @nanmean)
ip.parse(varargin{:});
Opt = ip.Results;

if isstruct(Opt.fun)
    structMode = true;
else
    structMode = false;
end

dim = dim+Opt.basedim;

T = struct();
for field = fieldnames(S)'
    
    if ~all(cellfun(@isnumeric,{S.(field{1})}))
        continue
    end
    if structMode && ~ismember(field, fieldnames(Opt.fun))
        continue
    end

    res = {S.(field{1})};
    szS = num2cell(size(S)); % outer dimensions
    valuedSamples = ~cellfun(@isempty, res);
    szRes = size(res{find(valuedSamples,1)}); % inner dimensions
    emptySamples= ~valuedSamples;
    res(emptySamples) = repmat({nan(szRes)}, 1, sum(emptySamples));
    try
        res = cat(Opt.basedim+1, res{:}); 
    catch MatlabError
        warning('size inconsistency field=%s ... skipping...', field{1})
        continue
    end
    if any(szRes==0)
        continue
    end
    
    res = reshape(res, [szRes(1:Opt.basedim), szS{:}]);
    
    Opt.funargs{Opt.funargs_dimPosition} = dim;
    if structMode
        res = Opt.fun.(field)(res, Opt.funargs{:});
    else
        res = Opt.fun(res, Opt.funargs{:});
    end

    szRes = size(res);
    
    if numel(szRes) > Opt.basedim
        inds = cell( 1, numel(szRes(3:end)) );
        [inds{:}] = ind2sub(szRes(3:end), 1:numel(res(1,1,:)));
        inds = cat(1, inds{:});
    else
        inds = 1;
    end

    for ind = inds
        ind = num2cell(ind);
        T(ind{:}).(field{1}) = res(:,:,ind{:});
    end
end

if Opt.squeeze
    T = squeeze(T);
end
