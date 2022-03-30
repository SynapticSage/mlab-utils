function [t_midpoints, t_startends] = overlapping(epochPeriods, varargin)

ip = inputParser;
ip.addParameter('window', []);
ip.KeepUnmatched = true;
ip.parse(varargin{:})
Opt = ip.Results;

[t_midpoints, ~] = units.time.nonoverlapping(epochPeriods, Opt);

if isscalar(window)
    window = [-window(1)/2, window(2)/2];
end
assert(window(2) > window(1), 'End of window must be after start');

% get window edges around those time points (different knob for bin size here than samplingRate)
windowStarts = t_midpoints + window(1)/2;
windowStops =  t_midpoints + window(2)/2;
t_startends = [windowStarts; windowStops];
