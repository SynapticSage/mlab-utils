function results = binaryOp(op, results1,results2, varargin)

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