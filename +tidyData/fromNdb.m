function T = fromNdb(results, varargin)
% function T = fromNdb(results, varargin)
% Make a tidy table from nd list of similar struct objects

ip = inputParser;
ip.addParameter('addConstArgs', {});
ip.addParameter('dimLabelArgs', {});
ip.addParameter('broadcast',    true);
ip.addParameter('ignore',    []);
ip.addParameter('ignoreType',    []);
ip.addParameter('stringify',    true);
ip.addParameter('assertFields',   []);
ip.parse(varargin{:});
opt = ip.Results;

indices = ndBranch.indicesMatrixForm(results);

% Build super-table from table of each struct.
T = table();
first = 1;
P = ProgressBar(size(results,1), 'Title','Converting to table', 'Total', size(indices,1));
count = 0;
for ind = indices'

    result = ndb.get(results, ind);
    % Options to modify each struct
    if ~isempty(opt.stringify)
        result = nd.stringify(result);
    end
    if ~isempty(opt.broadcast)
        result = nd.broadcast(result);
    end
    if ~isempty(opt.addConstArgs)
        result = nd.addConst(result, opt.addConstArgs{:});
    end
    % Conveert to tidy
    t = tidyData.fromStruct(result,...
        'ignore', opt.ignore,...
        'ignoreType', opt.ignoreType);
    if height(t) == 0
        continue
    end
    count = count + 1;
    t.index = count;
    t.Properties.RowNames = {num2str(count)};
    if  first == 1
        P.printMessage("Table with fields: " + join(T.Properties.VariableNames,", "));
        first = 0;
        T = t;
    else
        % throw out columns with cell arrays
        T = clean(T);
        t = clean(t);
        T = outerjoin(T, t, 'mergekeys', true);
    end

    P.step([],[],[]);
end

P.release();

function t = clean(t)

    arr = table2cell(t(1,:));
    classes = cellfun(@class, arr,'UniformOutput',false);
    len = cellfun(@length, arr);
    % throw out classes = cell and len == 0
    t(:,classes == "cell" | len == 0) = [];
