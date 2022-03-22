function [Patterns, otherInfo] = get_stringFilt(filtstring, varargin)

ip = inputParser;
ip.KeepUnmatched = true;
ip.addParameter('server',false);
ip.parse(varargin{:});
Opt = ip.Results;
varargin = util.struct2varargin(ip.Unmatched);

% Get the summary of runs
T = table.get.summaryOfRuns(varargin{:});

% Find the entries to loa
T = query.table.getHashed_stringFilt(T, filtstring);

% Request to load those entries and combine their output
if Opt.server
    [Patterns, otherInfo] = query.pattern.tmpLoadAndCombine(T.hash);
else
    [Patterns, otherInfo] = query.pattern.loadAndCombine(T.hash);
end
