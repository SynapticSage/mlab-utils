function waitQueueSize(allowedJobsCount, pauseTime, cluster)
% function waitQueueSize(allowedJobsCountount, pauseTime, parcluster)

if nargin < 3 || isempty(pauseTime)
    pauseTime = 20;
end
if nargin < 2 || isempty(cluster)
 cluster = parcluster();
end

% Wait for batches
disp("Checking jobs running")
jobs = sum(string({cluster.Jobs.State}) == "running" | string({cluster.Jobs.State}) == "pending");
while jobs >= allowedJobsCount
   cluster.Jobs
   pause(pauseTime);
   jobs = sum(string({cluster.Jobs.State}) == "running" | string({cluster.Jobs.State}) == "pending");
end

