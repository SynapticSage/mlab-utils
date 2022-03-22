function [columns, indicator_variable] = getIndex(T, exc, varargin)
% Returns the index columns of the common table structure we refer to 
% 
% Inputs
% ------
% T : the table with data about runs and their performance metrics
% exc : a list of strings to exclude from the possible list of index variables
%   (exc is short for exclusion-list ... list of variables to exclude from the
%   final set of index columns, and potentially any entangled columns)
%   (entangled means index columns who are conditionally dependent on
%   eachother)
%
% Warning
% --------
% For this method to work aS expected, everytime a new option show up,
% we have to add it to the option_index_list below. I'm sure there's a
% clever, neat trick around this, but I'm in hack and slash mode.
%
% Returns
% --------
% columns : list of string
%   list of index columns (useful for the unstack function
% indicator_variable : vector
%   indicator_varaible signifying the groups of row who are unique combinations
%   of each possible combination of the index columns

ip = inputParser;
ip.addParameter('doOption', true);
ip.addParameter('removeEntangled', true);
ip.parse(varargin{:});
opt = ip.Results;


%% Some hard-coded property lists
%% ------------------------------
pattern_index_list = ["generateH", "source", "target", "iPartition",...
                      "patternType","directionality", "sourceArea",...
                      "nSource", "nTarget"];

if opt.doOption
    option_index_list = ["animal", "samplingRate", "timesPerTrial", "sourceArea",...
                        "equalWindowsAcrossPatterns", "numPartition", "binsToMatchFR",...
                        "quantileToMakeWindows", "preProcess_FilterLowFR",...
                        "preProcess_matchingDiscreteFR", "shortedRippleWindow"];
else
    option_index_list = [];
end

entangled_properties = {[]};

index_list = [pattern_index_list, option_index_list];

if nargin < 2 || isempty(exc) || ~isstring(exc)
    exc = string([]);
end

% Should we look for and add variables that would be entangled with the
% requested exclusion?
% if opt.removeEntangled
%     keyboard
%     entangled_vars = ["source"    "target"    "nSource"    "nTarget"    "sourceArea"    "numPartition"];
%     if any(ismember(exc, entangled_vars))
%         exc = union(exc, entangled_vars);
%     end
% end


%% Determine index columns
%% ------------------------------
% Find all columns who match our predefined list
columns = [];
for column = string(T.Properties.VariableNames)
    if ismember(column, index_list) && ...
            ~ismember(column, exc) && ...
            ~isequal(column,exc)
        columns = [columns, column];
    end
end

% Get the indicator variable from the groups formed by each of the index columns
if numel(columns) > 1
    grouping_vars = num2cell(table2array(T(:,columns)),1);
    indicator_variable = findgroups(grouping_vars{:});
else
    indicator_variable = [];
end
