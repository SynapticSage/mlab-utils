function correctMatches = files(animalDatatype, indexSearch, folder,  varargin)
% Return files that corresponds to an indexSearch
%
% Parameters
% ----------
%
% animalDatatype : string or char
%   `animalDatatype` is the string that describes the datatype in a filterframework filename
%
% indexSearch : list of integers, optional
%   List of integers to look for a single file up to as many as the `Opt.level`
%   allowed by the filetype in question.
%
%   if empty [], then look for * wildcard
%
% folder : char or string, optional
%   the folder to look within. if empty, it chooses `pwd`
%
% Output
% ------
%
% correctMatches : list of string
%   The list of files that matchStyle

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('level',[])
ip.addParameter('sort',false);
%ip.addParameter('indices',[]);
ip.addParameter('singleSearchError',false);
ip.addParameter('typeNotExistHandling','error');
ip.parse(varargin{:});
Opt = ip.Results;
if ~isempty(Opt.level)
    if Opt.level < size(indexSearch, 2)
        error("Requesting more indices per find request than there are levels!");
    end
end

if isstring(animalDatatype) && numel(animalDatatype) == 2
    animal = animalDatatype(1);
    datatype = animalDatatype(2);
    animalDatatype = char(join(animalDatatype, ""));
    typeExists = ndbFile.exist(animal, datatype);
    if ~typeExists
        if strcmp(Opt.typeNotExistHandling, 'error')
            error('type=%s does not exist',datatype);
        else
            correctMatches = [];
            return
        end
    end
else
    animal = [];
    datatype = [];
end

if nargin < 2 
    indexSearch = []; 
end
if nargin < 3 || isempty(folder)
    if ~isempty(animal) && ~isempty(datatype)
        folder = ndbFile.folder(animal, datatype);
    else
        folder = pwd;
    end
end

if isempty(Opt.level)
    test = string(nan(2,1));
    test = sprintf('%s/%s*.mat', folder, animalDatatype);
    Opt.level = ndbFile.level(test);
end

if ~iscell(indexSearch)
    if size(indexSearch,2) > Opt.level
        indexSearch = unique(indexSearch(:,1:Opt.level), 'rows');
    end
    if size(indexSearch,1) > 1
        indexSearch = num2cell(indexSearch, 2);
    end
end

if iscell(indexSearch) % <<< MULTIPLE SEARCHES >>>

    for i = 1:numel(indexSearch)
        O = Opt;
        O.indices  = indexSearch{i};
        correctMatches{i} = ndbFile.files(animalDatatype, indexSearch{i}, folder, O);
    end
    correctMatches = cat(1, correctMatches{:});

else % <<< ONE SEARCH >>>

    % Possible matchStyle names
    % -------------------
    if ~isempty(indexSearch)
        idxStr = sprintf('%02d-', indexSearch(:)); % 1
        if ~isempty(Opt.level) && Opt.level > numel(indexSearch)
            %for i = 1:(Opt.level - numel(indexSearch))-1 % 2 through N
            for i = 1:(Opt.level - numel(indexSearch)) % 2 through N
                %idxStr = [idxStr repmat('*-', 1, Opt.level-numel(indexSearch))];
                idxStr = [idxStr repmat('*-', 1, 1)];
            end
        end
        idxStr = idxStr(1:end-1);
    else
        idxStr = '*';
    end

    % Encode the possible styles of filterframework esque files we could
    % attempt to match
    matchStyle = string(nan(2,1));
    matchStyle(1) = sprintf('%s/%s%s.mat', folder, animalDatatype, idxStr);
    matchStyle(2) = sprintf('%s/%s%s.mat', folder, animalDatatype, ['-' idxStr]);
    if isempty(indexSearch)
        matchStyle(3) = sprintf('%s/%s.mat', folder, animalDatatype);
    end



    % Return first possible matchStyle name that exists
    % -------------------------------------------
    for i = 1:numel(matchStyle)
        correctMatches = dir(matchStyle(i)); 
        if ~isempty(correctMatches)
            % If indexSearch was never given
            if isempty(indexSearch)
                deletion = [];
                for f = 1:numel(correctMatches)
                    l =  strfind(correctMatches(f).name, animalDatatype);
                    l = l + strlength(animalDatatype);
                    %if ~ismember( correctMatches(f).name(l), '0123456789.' )
                    if ~ismember( correctMatches(f).name(l), '0123456789.-_' )
                    
                        deletion = [deletion, f];
                    end
                end
                correctMatches(deletion) = [];
            end
            % Subset any specific indices requested by user
            if ~isempty(indexSearch)
                matches = false(1,numel(correctMatches));
                for f = 1:numel(correctMatches)
                    fileInd = ndbFile.index(correctMatches(f).name);
                    N = min(size(fileInd,2),  size(indexSearch,2));
                    matches(f) = ismember(fileInd(1:N), indexSearch(:,1:N), 'rows');
                end
                correctMatches = correctMatches(matches);
            end
            if Opt.sort
                argsort = sort({correctMatches.name});
                correctMatches = correctMatches(argsort);
            end
            
            % If a style match was used, then we do not need to search files
            % that match other styles
            return

        end
    end

    % Generate an error if not found
    % ------------------------------
    if Opt.singleSearchError && isempty(correctMatches)
         error('ndbFile.files search did not return any files')
    end

end


% Generate an error if not found
% ------------------------------
%if isempty(correctMatches)
%     error('None of ndbFile.files searches returns a file')
%end
