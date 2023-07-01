function results = binaryOp(op, results1,results2, varargin)
% binaryOp - apply a binary operation to two sets of results
%
% Syntax:
%   results = binaryOp(op, results1,results2)
%
% Inputs:
%   op - function handle to binary operation
%   results1 - first set of results
%   results2 - second set of results
%
% Outputs:
%   results - results of applying op to results1 and results2
%

ip = inputParser;
ip.addParameter('omitnan',true);
ip.addParameter('excludeFields',[]);
ip.parse(varargin{:});
opt = ip.Results;

indices1 = nd.indicesMatrixForm(results1);
indices2 = nd.indicesMatrixForm(results2);
indices = indices1(ismember(indices1,indices2,'rows'),:);

results = repmat(struct(),size(results1));
for index = indices'
    I = num2cell(index);
    for field = string(fieldnames(results1))'
        if ismember(field,opt.excludeFields)
            results(I{:}).(field) = results1(I{:}).(field);
        else
            try
                if opt.omitnan
                    results1(I{:}).(field)=omitnan(results1(I{:}).(field));
                    results2(I{:}).(field)=omitnan(results2(I{:}).(field));
                end
                results(I{:}).(field) = op(results1(I{:}).(field), ...
                                           results2(I{:}).(field));
            catch ME
                %warning('Cannot operate on %s', field)
            end
        end
    end
end

function x = omitnan(x)
inds = isnan(x);
x(inds) = 0;
