function indices = indicesMatrixForm(animal, datatype, varargin)
% INDICESMATRIXFORM returns indices of branchedCell files in matrix form

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('asNd', false)
ip.addParameter('asTidy', false)
ip.addParameter('simplefilter', '');
ip.addParameter('level',[]);   % how leveled show the matfile we grab be (0,1,2,3...etc)
ip.addParameter('indices',[]); % used to match indices (day, epoch, tetrode, etc) ... use nan to select all of a level
ip.addParameter('ind',[]); 
ip.addParameter('inds',[]); 
ip.parse(varargin{:});
Opt = ip.Results;
Opt.animal = animal;

if isempty(Opt.indices)
    if ~isempty(Opt.ind)
        Opt.indices = Opt.ind;
    elseif ~isempty(Opt.inds)
        Opt.indices = Opt.inds;
    end
end

% Whatever  we do in this function, let's make sure we come home
currdir = pwd;
cleanup = onCleanup(@() cd(currdir));

% How  find the files
filefilter = "*" +  Opt.animal + string(datatype) + "*";
folder = ndbFile.folder(animal, datatype, ip.Unmatched);

% Find and sort the files
files = ndbFile.files([string(animal), string(datatype)],...
    Opt.indices, folder,...
    'level', Opt.level);

% Find a super structure
fCount = 0;
indices = [];
if isempty(files)
    warning('No files found');
else
    for file = files'
        indices = [indices; ndbFile.index(file.name)];
    end
end
