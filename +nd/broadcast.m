function results = broadcast(results, varargin)
% function results = broadcast(results, varargin)
% BROADCAST Broadcast each field of the struct to match other fields
%
% Parameters
% ----------
% results : struct
%   Struct of results to broadcast
% allow1 : bool, optional
%   Allow broadcasting of 1 dimension arrays. Default: false
% allowchar : bool, optional
%   Allow broadcasting of char arrays. Default: false
%
% Returns
% -------
% results : struct



ip = inputParser;
ip.addParameter('allow1', false);
ip.addParameter('allowchar', false);
ip.parse(varargin{:});
opt = ip.Results;

% Get sizes of each field and munge to allow checking each size up to
% maximal dimensions
sizes = structfun(@size,results(1),'UniformOutput',false);
if ~opt.allowchar
    illegalvars = structfun(@ischar, results(1));
    fields = fieldnames(results(1));
    sizes = rmfield(sizes, fields(illegalvars));
else
    illegalvars = false(size(sizes));
end

% Extend all current dimensions to maximal dimension we will work with
max_ndims = max(cellfun(@numel, struct2cell(sizes)));
for field = fieldnames(sizes)'
    field_ndims = numel(sizes.(field{1}))+1;
    sizes.(field{1})(field_ndims:max_ndims+1) = 1;
end

% Figure out the most common dimensions for each fields size dimensions
sizesCell = struct2cell(sizes);
dimvalues = cat(1,sizesCell{:});
modeDims = (1:max_ndims)';
for ndim = 1:max_ndims
    DV = dimvalues(:,ndim);
    if ~opt.allow1 && ~all(DV==1)
        DV(DV == 1) = [];
    end
    modeDims(ndim,2) = mode(DV);
end

% Iterate and broadcast
acceptableDimensions = [1; modeDims(:,2)];
indices = nd.indicesMatrixForm(results);
fields = string(fieldnames(results));
for index = indices'
    for field = fields(~illegalvars)'
        I = num2cell(index);
        fieldSize = size(results(I{:}).(field));
        if max_ndims-numel(fieldSize) > 0
            fieldSize = [fieldSize, ones(1, max_ndims-numel(fieldSize))];
        end
        % Broadcast?
        if all(ismember(fieldSize, acceptableDimensions))
            broadcastInstruction = fieldSize(1:max_ndims) == modeDims(1:max_ndims,2)';
            pullInstruction = broadcastInstruction == 0;
            broadcastInstruction = double(broadcastInstruction);
            broadcastInstruction(pullInstruction) = ...
                modeDims(pullInstruction, 2);
            results(I{:}).(field) = ...
                repmat(results(I{:}).(field), broadcastInstruction);
        end
    end
end
