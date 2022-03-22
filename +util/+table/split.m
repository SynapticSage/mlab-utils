function Tnew = split(T, props)
% Split table T by properties props into cell of tables T

gstruct = util.table.findgroups(T, props);
Tnew = cell(1, numel(gstruct.uGroups));
for group = progress(gstruct.uGroups','Title', 'Splitting')
    Tnew{group} = T(gstruct.time.groups == group, :);
    %for i = 1:numel(gstruct.conditionLabels)
    %    Tnew{group}.(gstruct.conditionLabels(i)) = ...
    %        repmat(gstruct.group.valuesByGroupNum{i}(group), height(T), 1);
    %end
end
