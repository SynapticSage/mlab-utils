function varargout = load(animal, datatype, varargin)
% General load for all nd branch objs

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('asNd',   false)
ip.addParameter('asTidy', false)
ip.addParameter('get', false);
ip.addParameter('simplefilter', '');
ip.addParameter('level',  []);   % how leveled show the matfile we grab be (0,1,2,3...etc)
ip.addParameter('indices',[]); % used to match indices (day, epoch, tetrode, etc) ... use nan to select all of a level
ip.addParameter('ind',[]); % used to match indices (day, epoch, tetrode, etc) ... use nan to select all of a level
ip.parse(varargin{:});
opt = ip.Results;
opt.animal = animal;

if ~isempty(opt.ind) && isempty(opt.indices)
    opt.indices = opt.ind;
end

% Whatever  we do in this function, let's make sure we come home
currdir = pwd;
cleanup = onCleanup(@() cd(currdir));

% How  find the files
filefilter = "*" +  opt.animal + string(datatype) + "*";
folder = ndbFile.folder(animal, datatype, ip.Unmatched);

% Find and sort the files
files = ndbFile.files(string(animal) + string(datatype),...
    [], folder,...
    'level', opt.level,...
    'indices', opt.indices);

% Find a super structure
fCount = 0;
if isempty(files)
    warning('No files found');
    res = {};
else
    for file = files'

        % If a simple grep filter is passed
        if ~isempty(opt.simplefilter) && ~contains(file.name, opt.simplefilter)
            continue
        end
        if ~endsWith(file.name,'.mat')
            continue
        end

        fCount = fCount + 1;
        if fCount  == 1
            res = load([file.folder filesep file.name]);
            res = res.(datatype);
            indices = ndBranch.indicesMatrixForm(res);
            if ~isempty(opt.indices)
                N = min(size(indices,2), size(opt.indices,2));
                filt = ismember(indices(:,1:N), opt.indices(:,1:N), 'rows');
                nullindices = indices(~filt,:);
            else
                nullindices = [];
            end
            for index = nullindices'
                res = ndBranch.set(res, index, []);
            end
        else
            tmp = load([file.folder filesep file.name]);
            tmp = tmp.(datatype);
            indices = ndBranch.indicesMatrixForm(tmp);
            if ~isempty(opt.indices)
                N = min(size(indices,2), size(opt.indices,2));
                filt = ismember(indices(:,1:N), opt.indices(:,1:N), 'rows');
                indices = indices(filt,:);
            end
            for index = indices'
                res = ndBranch.set(res, index, ndBranch.get(tmp, index));
            end
        end
    end
end

if opt.asNd && opt.asTidy
    error('Not implemented yet. Will be ndb -> nd -> tidy');
elseif opt.asNd 
    res = ndBranch.toNd(res);
elseif opt.asTidy
    Params = ip.Unmatched;
    Params.datatype = datatype;
    res = tidyData.fromNdBranch_tidy(res, Params);
end

if opt.get
    res = ndb.get(res,opt.indices);
end

% Output or load caller workspace
if nargout == 0
    assignin('caller',datatype,res);
else
    varargout{1} = res;
    if nargout == 2 && opt.asNd == false
        varargout{2} = ndBranch.type(res);
    end
end
