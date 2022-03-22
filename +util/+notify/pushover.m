function varargout=pushover(varargin)
% PUSHOVER - Push notifications to the <a href="http://pushover.net">Pushover</a> service.
% 
% pushover
%   Prints this help, the available options for the 'sound' setting and the
%   currently saved (or default) preferences.
%
% OPTS=pushover
%   Returns a structure OPTS with the current default options.
%
% pushover(OPTS)
%   Saves the structure options as defaults.
%
% [retrStr,status]=pushover(TITLE,MESSAGE,OPTS)
%                 =pushover(TITLE,MESSAGE)
%                 =pushover(MESSAGE,OPTS)
%   OPTS - settings to send a message.
%   MESSAGE - Message to send. Limited to 512 characters.
%
% OPTS - Default Options.
%           token: 'DogErTJffntjvzbNXMVn3EoycDOWdN'
%            user: ''
%         message: ''
%          device: ''
%           title: ''
%             url: ''
%       url_title: ''
%        priority: ''
%       timestamp: ''
%           sound: 'pushover'
% For full description of options see the <a href="https://pushover.net/api">Pushover REST API</a>
%
% timestamp is in Matlab serial date instead of Unix timestamp. This allows
%   for better integration with Matlab. If timestamp is a string 'datenum'
%   is run to turn it into a serial date.
%
% By default 'title' defaults to the calling function if empty. If pushover is
%   called within myApp.m the title is set to 'myApp'. If called from the
%   command line it defaults to empty.
%
% If API token is empty (opts.token='') then the falls back to sendmail.
%   (sendmail must be configured: <a href="http://www.mathworks.com/support/solutions/en/data/1-3PRRDV/">sendmail setup</a>)
%
% Pushover apps are limited to 7,500. If you plan on using pushover.m,
%   please create your own application at <a href="https://pushover.net/apps/build">https://pushover.net/apps/build</a> (<a href="http://www.mathworks.com/matlabcentral/fileexchange/24085">Matlab Icon</a>)
%
% Pushover Clients: <a href="https://pushover.net/clients/android">Android</a> & <a href="https://pushover.net/clients/ios">iOS</a>
%
% See also urlread, sendmail, pushoverExamples
%
% Examples:
% % Minimum required to send message.
% opts.user='ohterejqucyumllhnnvuqjvnjywoqp'; % From your <a href="https://pushover.net/login">Dashboard</a>
% pushover('Hello World!',opts);
%
% % Set default device to phone and sound to 'Piano Bar'.
% opts.sound='pianobar';
% opts.device='phone';
% pushover(opts);
%
% % Send message via e-mail gateway with title FooBar
% opts.token='';
% pushover('Hello World','FooBar',opts);
%
% To clear all preferences:
% rmpref('pushover');

% Copyright 2012
% Jedediah Frey
% Code used from:
%   JSON Parser: http://www.mathworks.com/matlabcentral/fileexchange/20565

%% Default Settings
% https://pushover.net/api
% Required settings

% location = which('util.notify.pushover');
% location = fileparts(location);
% defaults.token=strip(fileread(fullfile(location, 'pushover.apitoken')));

if isstring(varargin{1})
    varargin{1} = char(varargin{1});
end
if numel(varargin) >1 && isstring(varargin{2})
    varargin{2} = char(varargin{2});
end

defaults.token='DogErTJffntjvzbNXMVn3EoycDOWdN';
defaults.user='';
defaults.message='';
% Optional settings
defaults.device='';
defaults.title='';
defaults.url='';
defaults.url_title='';
defaults.priority='';
defaults.timestamp='';
defaults.sound='pushover';
% API Settings
config.apiurl='https://api.pushover.net/1/messages.json';
config.method='post';
config.email='api.pushover.net';
config.soundurl='https://api.pushover.net/1/sounds.json';
% Get defaults from either saved preferences (if set) or above settings.
defaults=getDefaults(defaults);
% Test internet connectivity
if ~ispref(mfilename,'firstrun')
    firstrun;
end
%% Input processing
% Given 0 inputs.
if nargin==0
    % If the user wants the current options assign them.
    if nargout==1
        varargout{1}=defaults;
    end
    % Print the help for the script.
    help(mfilename('fullfile'));
    printSounds(config.soundurl);
    printOpts(defaults);
    % Exit
    return;
end
% If only 1 input is given and it is an opts struct then save the defaults.
if nargin==1&&isstruct(varargin{1})
    opts=varargin{1};
    optFields=fieldnames(opts);
    GROUP=mfilename;
    for i=1:numel(optFields)
        if strcmpi('saveDefault',optFields{i})||strcmpi('message',optFields{i}); % Don't save the save option
            continue;
        end
        tmpOpt=opts.(optFields{i});
        switch class(tmpOpt)
            case 'double'
                fprintf('\tSaving: %s=%d\n',optFields{i},tmpOpt);
            otherwise
                % Else use fprintf to print the options.
                fprintf('Saving: %s=%s\n',optFields{i},tmpOpt);
        end
        setpref(GROUP,optFields{i},opts.(optFields{i}))
    end
    disp('Default options saved');
    % If only the input options were given return.
    if nargin==1
        return;
    end
end
% Find the input options. If not specified use the default/saved options.
optsIdx=find(cellfun(@isstruct,varargin));
if length(optsIdx)>1
    error('Multiple structures given as input');
elseif isempty(optsIdx)
    opts=defaults;
else
    opts=varargin{optsIdx};
    varargin(optsIdx)='';
    % Loop through all needed option fields.
    optFields=fieldnames(defaults);
    for i=1:numel(optFields)
        % If field isn't specified.
        if ~isfield(opts,optFields{i})
            % Use the default/saved option.
            opts.(optFields{i})=defaults.(optFields{i});
        end
    end
end
% Assign inputs.
switch numel(varargin)
    case 1
        opts.message=varargin{1};
    case 2
        opts.title=varargin{1};
        opts.message=varargin{2};
    otherwise
end
% Convert doubles to strings.
if ~isempty(opts.priority)
    switch opts.priority
        case {'1',1}
            opts.priority='1';
        case {'0',0}
            opts.priority='0';
        case {'-1',-1}
            opts.priority='-1';
        otherwise
            opts.priority=0;
    end    
end
%% PreProcessing
% Test if the user is specified.
if isempty(opts.user)
    error('User key is empty. Set with opts.user and save for future use');
end
% Test message length
if isempty(opts.message)
    error('Message is empty. Set with opts.message or as first input');
end
if length(opts.message)>512
    warning('PUSHOVER:MSGLEN','Message length limited to 512 characters. Truncating.');
    opts.message=opts.message(1:512);
end
% Check for title.
if isempty(opts.title)
    S=dbstack;
    if length(S)>1
       opts.title=S(2).name;
    end
end
if ~isempty(opts.timestamp)
    % If it is a string, run through date num to turn it into a 
    if isa(opts.timestamp,'char')
        opts.timestamp=datenum(opts.timestamp);
    end
    % Convert Matlab serial date to Unix timestamp.
    opts.timestamp=int32(floor(86400*(opts.timestamp-datenum('01-Jan-1970'))));
    % Convert back into a string for the urlread
    opts.timestamp=sprintf('%d',opts.timestamp);
end
%% Clear unused fields.
clearableFields={'device','title','url','url_title','priority','timestamp','sound'};
for clearableField=clearableFields
    switch class(opts.(clearableField{1}))
        case 'double'
            if opts.(clearableField{1})==0
                opts=rmfield(opts,clearableField{1});
            end
        case 'char'
            if isempty(opts.(clearableField{1}))
                opts=rmfield(opts,clearableField{1});
            end
        case 'int32'
            % Do nothing since 0 is epoch.
        otherwise
            error('Unknown type: %s',class(opts.(clearableField{1})));
    end
end
%% Processing.
% See if the token is empty.
if isempty(opts.token)
    if isfield(opts,'device')
        toEmail=sprintf('%s+%s@%s',opts.user,config.email);
    else
        toEmail=sprintf('%s@%s',opts.user,config.email);
    end
    if isfield(opts,'title')
        sendmail(toEmail,opts.title,opts.message);
    else
        sendmail(toEmail,'MATLAB',opts.message);
    end
else % Use HTTP API
    param = fieldnames(opts);
    value = struct2cell(opts);
    post=[param,value]';
    post=reshape(post,1,numel(post));
    [str,status]=urlread(config.apiurl,config.method,post);
    if status==0
        warning('PUSHOVER:FAILED','Post failed.');
    end
    switch nargout
        case 1
            varargout{1}=str;
        case 2
            varargout{1}=str;
            varargout{2}=status;
        otherwise
            
    end
end
end

%% Helper Functions
%% function firstrun
function firstrun
% Run on the first time to make sure stuff is setup correctly.
[~,status]=urlread('https://pushover.net');
if status==0
    error('PUSHOVER:NONET','Could not connect to Pushover to test internet connectivity.\n\nCheck your proxy settings:\n\thttp://www.mathworks.com/support/solutions/en/data/1-19J5C/?solution=1-19J5C');
end
setpref(mfilename,'firstrun','');
end
%% function defaults=getDefaults(fields,default)
% Gets the preferences for the current mfile or sets the option based on
% defaults.
function defaults=getDefaults(opts)
GROUP=mfilename;
fields=fieldnames(opts);
for i=1:numel(fields)
    defaults.(fields{i})=getpref(GROUP,fields{i},opts.(fields{i}));
end
end
%% function printOpts(opts)
function printOpts(opts)
% Print off 'Defaults header'
fprintf('\nDefaults:\n');
% For each of the available option settings.
optFields=fieldnames(opts);
optFields=reshape(optFields,1,numel(optFields));
for i=1:numel(optFields)
    field=optFields{i};
    switch class(opts.(field))
        case 'logical'
            % If the field is a logical fprintf won't work, workaround.
            if opts.(field)
                fprintf('\t%-11s - true\n',field);
                else5
                fprintf('\t%-11s - false\n',field);
            end
        case 'double'
            fprintf('\t%-11s - %d\n',field,opts.(field));
        otherwise
            % Else use fprintf to print the options.
            fprintf('\t%-11s - ''%s''\n',field,opts.(field));
    end
end
end
%% function printSound(soundurl)
function printSounds(soundurl)
% Print 
[soundJSON,status]=urlread(soundurl);
if status==1
    data=parse_json(soundJSON);
    sound=fieldnames(data{1}.sounds);
    soundFull=struct2cell(data{1}.sounds);
    soundCell=[soundFull sound]';
    fprintf('Available options for sound setting:\n');
    fprintf('\t%s: ''%s''\n',soundCell{:})    
end
end
%% function [data json] = parse_json(json)

function [data json] = parse_json(json)
% [DATA JSON] = PARSE_JSON(json)
% This function parses a JSON string and returns a cell array with the
% parsed data. JSON objects are converted to structures and JSON arrays are
% converted to cell arrays.
%
% Example:
% google_search = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=matlab';
% matlab_results = parse_json(urlread(google_search));
% disp(matlab_results{1}.responseData.results{1}.titleNoFormatting)
% disp(matlab_results{1}.responseData.results{1}.visibleUrl)

    data = cell(0,1);

    while ~isempty(json)
        [value json] = parse_value(json);
        data{end+1} = value; %#ok<AGROW>
    end
end

function [value json] = parse_value(json)
    value = [];
    if ~isempty(json)
        id = json(1);
        json(1) = [];
        
        json = strtrim(json);
        
        switch lower(id)
            case '"'
                [value json] = parse_string(json);
                
            case '{'
                [value json] = parse_object(json);
                
            case '['
                [value json] = parse_array(json);
                
            case 't'
                value = true;
                if (length(json) >= 3)
                    json(1:3) = [];
                else
                    ME = MException('json:parse_value',['Invalid TRUE identifier: ' id json]);
                    ME.throw;
                end
                
            case 'f'
                value = false;
                if (length(json) >= 4)
                    json(1:4) = [];
                else
                    ME = MException('json:parse_value',['Invalid FALSE identifier: ' id json]);
                    ME.throw;
                end
                
            case 'n'
                value = [];
                if (length(json) >= 3)
                    json(1:3) = [];
                else
                    ME = MException('json:parse_value',['Invalid NULL identifier: ' id json]);
                    ME.throw;
                end
                
            otherwise
                [value json] = parse_number([id json]); % Need to put the id back on the string
        end
    end
end

function [data json] = parse_array(json)
    data = cell(0,1);
    while ~isempty(json)
        if strcmp(json(1),']') % Check if the array is closed
            json(1) = [];
            return
        end
        
        [value json] = parse_value(json);
        
        if isempty(value)
            ME = MException('json:parse_array',['Parsed an empty value: ' json]);
            ME.throw;
        end
        data{end+1} = value; %#ok<AGROW>
        
        while ~isempty(json) && ~isempty(regexp(json(1),'[\s,]','once'))
            json(1) = [];
        end
    end
end

function [data json] = parse_object(json)
    data = [];
    while ~isempty(json)
        id = json(1);
        json(1) = [];
        
        switch id
            case '"' % Start a name/value pair
                [name value remaining_json] = parse_name_value(json);
                if isempty(name)
                    ME = MException('json:parse_object',['Can not have an empty name: ' json]);
                    ME.throw;
                end
                data.(name) = value;
                json = remaining_json;
                
            case '}' % End of object, so exit the function
                return
                
            otherwise % Ignore other characters
        end
    end
end

function [name value json] = parse_name_value(json)
    name = [];
    value = [];
    if ~isempty(json)
        [name json] = parse_string(json);
        
        % Skip spaces and the : separator
        while ~isempty(json) && ~isempty(regexp(json(1),'[\s:]','once'))
            json(1) = [];
        end
        [value json] = parse_value(json);
    end
end

function [string json] = parse_string(json)
    string = [];
    while ~isempty(json)
        letter = json(1);
        json(1) = [];
        
        switch lower(letter)
            case '\' % Deal with escaped characters
                if ~isempty(json)
                    code = json(1);
                    json(1) = [];
                    switch lower(code)
                        case '"'
                            new_char = '"';
                        case '\'
                            new_char = '\';
                        case '/'
                            new_char = '/';
                        case {'b' 'f' 'n' 'r' 't'}
                            new_char = sprintf('\%c',code);
                        case 'u'
                            if length(json) >= 4
                                new_char = sprintf('\\u%s',json(1:4));
                                json(1:4) = [];
                            end
                        otherwise
                            new_char = [];
                    end
                end
                
            case '"' % Done with the string
                return
                
            otherwise
                new_char = letter;
        end
        % Append the new character
        string = [string new_char]; %#ok<AGROW>
    end
end

function [num json] = parse_number(json)
    num = [];
    if ~isempty(json)
        % Validate the floating point number using a regular expression
        [s e] = regexp(json,'^[\w]?[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?[\w]?','once');
        if ~isempty(s)
            num_str = json(s:e);
            json(s:e) = [];
            num = str2double(strtrim(num_str));
        end
    end
end
