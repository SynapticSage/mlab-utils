function base = update(base, append, structfunLambda)
% util.struct.update(base, append, structfunLambda)
%
% Inspired by python's dictionary updatee method
%
% optional to apply a lambda to an appending struct

if ~isstruct(append)
    error("append must be of type struct");
end

if nargin > 2 && ~isempty(structfunLambda)
    append = structfun(structfunLambda, append, 'UniformOutput', false);
end

if isscalar(base) && isscalar(append)
    for field = string(fieldnames(append))'
        base.(field) = append.(field);
    end
else

    if isscalar(base)
        base = repmat(base, size(append));
    elseif isscalar(append)
        append = repmat(append, size(base));
    end

    indsB = nd.indicesMatrixForm(base);
    indsA = nd.indicesMatrixForm(append);
    if isequal(indsA, indsB)
        for ind = indsA'
            ind = num2cell(ind);
            base(ind{:}) = util.struct.update(base(ind{:}), append(ind{:}));
        end
    else
        error("Size mismatch! Must either be equal size or broadcastable sizes");
    end

end
