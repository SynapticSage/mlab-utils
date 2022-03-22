function C = splitByToCell(T, by)
% Split a tablle into a cell of tables by some list of tablle-columns


gstruct = util.table.findgroups(T, by);
for g = gstruct.uGroups'
    filt = gstruct.time.groups == g;
    C{g} = T(filt);
    T(filt) = [];
    gstruct.time.groups(filt) = [];
end
