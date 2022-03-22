function varargout = matfiles(animal, datatype, varargin)
% General load for all nd branch objs

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('asNd', false)
ip.addParameter('asTidy', false)
ip.addParameter('simplefilter', '');
ip.addParameter('level',[]);   % how leveled show the matfile we grab be (0,1,2,3...etc)
ip.addParameter('indices',[]); % used to match indices (day, epoch, tetrode, etc) ... use nan to select all of a level
ip.parse(varargin{:});
opt = ip.Results;
opt.animal = animal;

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

        if ~isempty(opt.indices)
            index = ndbFile.index(file.name);
            N = min(size(index,2), size(opt.indices,2));
            filt = ismember(index(1:N), opt.indices(:,1:N), 'rows');
            if ~filt
                continue % Not a part of users requested set
            end
        end

        % If a simple grep filter is passed
        if ~isempty(opt.simplefilter) && ~contains(file.name, opt.simplefilter)
            continue
        end
        if ~endsWith(file.name,'.mat')
            continue
        end

        fCount = fCount + 1;
        if fCount  == 1
            res = {matfile([file.folder filesep file.name])};
        else
            tmp = matfile([file.folder filesep file.name]);
            indices = ndBranch.indicesMatrixForm(tmp);
            res{end+1} = tmp;
        end

    end
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
