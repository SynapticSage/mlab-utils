function I = index(file)
% Returns the numeric index of an ndimensional
% branched cell file
%
% Example
% RY16lfp-01-09-12-23.mat = [1,9,12,23]
% RY16lfp01-09-12-23.mat = [1,9,12,23]

% Throw away patth ext
[~, file, ~] = fileparts(file);

file = string(split(file,'-'));

% Delete all particles that don't end with a digit
while ~isstrprop(lastCharacter(file(1)),'digit')
    file(1) = [];
    if  isempty(file)
        I=[];
        return
    end
end

% The first one might have alpha beforee digits: reemove it
file(1) = deleteToLastAlpha(file(1));

I = str2double(file)';

if numel(file) > 1 && isa(I,'double') && any(isnan(I)) 
    error("Failed to get index")
end

function c = lastCharacter(fstr) 
    fstr = char(fstr);
    c = fstr(end);

function file = constrainFirstToLastInt(file)
    firstNumeric = find(isstrprop(file,'digit'),1,'first');
    lastNumeric = find(isstrprop(file,'digit'),1,'last');
    file=file(firstNumeric:lastNumeric);

function file = deleteToLastAlpha(file)
    file = char(file);
    lastAlpha = find(isstrprop(file,'alpha'),1,'last');
    file(1:lastAlpha) = [];
    file = string(file);
