function [t_midpoints, t_startends] = nonoverlapping(epochPeriods, varargin)

ip = inputParser;
ip.addParameter('samplingPeriod', []);
ip.addParameter('nSamples', []);
ip.parse(varargin{:})
Opt = ip.Results;

if isa(epochPeriods,'single')
    Opt.samplingPeriod = single(Opt.samplingPeriod);
end

t_startends = [];
if ~isempty(Opt.nSamples)
    for epoch = 1:size(epochPeriods, 1)
        start = epochPeriods(epoch, 1);
        stop =  epochPeriods(epoch, 2);
        t_startends = [t_startends, linspace(start, stop, Opt.nSamples)];
    end
elseif ~isempty(Opt.samplingPeriod)
    for epoch = 1:size(epochPeriods, 1)
        start = epochPeriods(epoch, 1);
        stop =  epochPeriods(epoch, 2);
        t_startends = [t_startends, start:Opt.samplingPeriod:stop];
    end
else
    error('Must provide nSamples or samplingPeriod');
end

t_midpoints = [t_startends(1:end-1)',...
    t_startends(2:end)'];
t_midpoints = mean(t_midpoints,2)';

if all(t_midpoints==0)
    error('Fuck'); 
end

if ~util.isunique(t_midpoints)
    warning('Spike times not unique')
    keyboard;
end

