function renameStruct(animal, datatype, to, from, inds)
% Renames an internal struct in an NDB file

if nargin < 5; inds = []; end
files = ndbFile.files([string(animal), string(datatype)],...
    inds);

ff=@fullfile;

disp("Changing animal=" + animal + " datatype=" +datatype + " struct from=" + ...
            from + " to=" +to);

for file = progress(files(:)', 'Title', 'Renaming NDB single stuct items')
    M = matfile(ff(file.folder,file.name),'writable',true);
    if isempty(from)
        field = setdiff(fieldnames(M), ["Properties", "Row"]);
    else
        field = from;
    end

    if string(to) == string(field) || ~ismember(field, fieldnames(M))
        continue
    end

    if ~ismember(to, fieldnames(M))
        M.(to) = M.(field);
        M.(field) = [];
    end
    if ismember(field, fieldnames(M))
        util.matfile.rmsinglevar(char(ff(file.folder,file.name)), field);
    end
    clear M
end

