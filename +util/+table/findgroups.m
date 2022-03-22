function gstruct = findgroups(tab, conditionLabels)
% Accepts either a table or a struct that looks like a table
%
% Example: 
%
% >> gstruct = util.table.findgroups(beh, 'traj');
% >> gstruct
%
% gstruct =
% struct with fields:
%     conditionLabels: "traj"
%     uGroups: [318x1 double]
%     nGroups: 318
%     time: [1x1 struct]
%     group: [1x1 struct]
%     evalstring: ["$traj == 1"    "$traj == 2"    "$traj == 3"    "$traj == 4"    "$traj == 5"    "$traj == 6"    "$traj == 7"    "$traj == 8"    "$traj == 9"    "$traj == 10"    "$traj == 11"    "$traj == 12"    ...    ]
%
% >> gstruct.group
%
% ans =
% struct with fields:
%    values: {[318x1 single]}
%    field: [1x1 struct]
%    address: {[318x1 single]}
%    addressByGroupNum: {318x1 cell}
%    valuesByGroupNum: {318x1 cell}




if isstruct(tab)
    tab = struct2table(tab);
end

conditionLabels = string(conditionLabels);

conditionals              = cell(1,numel(conditionLabels));
conditions                = num2cell(table2array(tab(:, conditionLabels)),1);
addressConditionals       = num2cell(table2array(tab(:, conditionLabels)),1);
[groups, conditionals{:}] = findgroups(conditions{:});
groups(isnan(groups))     = -1;
uGroups                   = unique(groups);
uGroups                   = uGroups(uGroups>0);

gstruct.conditionLabels = conditionLabels;
gstruct.uGroups         = uGroups;
gstruct.nGroups         = numel(uGroups);
gstruct.time.groups     = groups;
gstruct.group.values    = conditionals;

addressConditionals = {};
for l = 1:numel(conditionLabels)
    label = conditionLabels(l);
    X = conditionals{l}(groups(groups > 0));
    gstruct.time.field.(label) = nan(size(conditionals{l}));
    gstruct.time.field.(label)(groups>0) = X;
    if isnumeric(conditionals{l})
        isAPositiveInt = isequal(round(conditionals{l}), conditionals{l});
        if isAPositiveInt
            isAPositiveInt = isAPositiveInt && all(conditionals{l} > 0, 'all');
        end
    else
        isAPositiveInt = false;
    end
    if isAPositiveInt
        addressConditionals{l} = gather(conditionals{l});
    else
        addressConditionals{l} = int32(categorical(conditionals{l}));
    end
    gstruct.group.field.(label) = nan(1, numel(uGroups));
    for g = uGroups
        gstruct.group.field.(label)(g) = conditionals{l}(g);
    end
end
gstruct.group.address           = addressConditionals;
gstruct.group.addressByGroupNum = cat(2, addressConditionals{:});
gstruct.group.addressByGroupNum = num2cell(gstruct.group.addressByGroupNum, 2);
gstruct.group.valuesByGroupNum = gather(cat(2, gstruct.group.values{:}));
gstruct.group.valuesByGroupNum = num2cell(gstruct.group.valuesByGroupNum, 2);

for g = uGroups'
    tmp = ["$"] + conditionLabels + " == " + string(gstruct.group.valuesByGroupNum{g});
    gstruct.evalstring(g) = join(tmp, " & ");
end
