function varargout = pushbullet(message, device)
% sends a  message to one or all devices
%
% if no input, then this will return the pushbullet object that can be used
% to query devices
%
% if one input, sends message to all devices
%
% if two input, sends message only to the device of interest




[location, ~] = fileparts(which('util.notify.pushbullet'));
key = strip(fileread(fullfile(location,'pushbullet.apitoken')));
p = util.notify.Pushbullet(key);

if nargin>=1
    if ischar(message) || iscellstr(message)
        message = string(message);
    end
    if numel(message) == 1
        message = repmat(message, 1,2);
    end
    message = cellstr(message);
end

if nargin == 0
    varargout{1} = p;
elseif nargin == 1
    p.pushNote([], message{1}, message{2});
elseif nargin == 2
    p.pushNote(device, message{1}, message{2});
else
    error('bad input');
end
