function batch(func, numOut, args, gs, jobs)
% function batch(func, numOut, args, gs, jobs)
% TODO this is WIP
error("Function not implemented properly yet")

if nargin < 5 && isempty(jobs)
    job = cell(1, numel(gs.uGroups));
end


% Condition-wise
address    = cellfun(@num2cell, num2cell(cat(2,gs.group.address{:}), 2), 'UniformOutput', false);
cluster    = parcluster;
exitProper = false;
destructor = onCleanup(@exitFunc);
for g = progress(gs.uGroups(end:-1:1)', 'Title', 'Submitting jercog conditions')

    if exist('job','var') && ~isempty(job{g}) 
        continue
    end

    util.job.waitQueueSize(4, 20, cluster);

    filtstr = "$" + gs.conditionLabels' + " == " + cellfun(@(x) string(x(g)), gs.group.values)';
    if ~isempty(Opt.argTransform)
        sub = util.cell.transform(Opt.argTransform, 1:2, {args, filterstr});
    else
        sub = args;
    end
    job{g} = batch(@coding.vectorCells.jercog.allNeurons_sparse_lean, 1, sub);
end

for g = progress(gs.uGroups(end:-1:1)', 'Title', 'Fetching outputs')
    tmp = fetchOutputs(job{g});
    sub.spikes = tmp{1};
    sub.spikes.jercog = util.struct.update(sub.spikes.jercog, gs.group.field, @(x) x(g)); % Add field information
    spikes.jercog.byGoal(address{g}{:}) = sub.spikes.jercog;
end

for g = progress(gs.uGroups(end:-1:1)', 'Title', 'Deleting jobs')
    delete(job{g});
end

exitProper = true;
return

function exitFunc()

    if exitProper
        assignin('base', 'jobsTmp', job);
    end
