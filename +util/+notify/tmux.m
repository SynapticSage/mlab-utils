function tmux(message, varargin)
% Causes tmux to notify the user. Useful for flashing that a process finished.

if nargin == 0
    message = '';
end

ip = inputParser;
ip.addParameter('time', []); % Time that the message is active for
ip.parse(varargin{:})
Opt = ip.Results;

if Opt.time
    % Sets how long the message displays
    command = sprintf('tmux set -g display-time %d', Opt.time);
    % NOTE : this knob right now is enforced to be an integer.
    system(command);
end

command = sprintf('tmux display-message "%s"', message);
system(command);
