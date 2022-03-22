function [requestedRowsAndColumns, requestedRows] = query(T, queryStr, varargin)
% Works like pandas.DataFrame.query() method in python
%
% Inputs
% ------
% queryStr : string or list of string
%   filtration expressions where '$var' translates to T.var
%   list of string translates to expresssion1 && expression2 ...
%
% varargin
% --------
%   first optional input will be a column or column of T to extract -- defaults too all columns
%   
%   subsequet keyword-arg pairs below
%   
%   arr : default true
%       return table2array(requestedRowsAndColumns)? 
%

ip = inputParser;
ip.addOptional('columns',':', @(x) true);
ip.addParameter('debug', false)
ip.addParameter('arr',true); % convert to array?
ip.parse(varargin{:});
opt = ip.Results;

if ischar(queryStr)
    queryStr  = string(queryStr);
elseif iscell(queryStr) || ...
        (isstring(queryStr) && numel(queryStr)>1)
    queryStr = join(queryStr, ' & ');
end
queryStr = queryStr.replace('$','T.').replace('''','"');
if opt.debug
    disp(queryStr);
end

% Get rows user requests
requestedRows = T(eval(queryStr),:);
% Get columns of rows user requests
requestedRowsAndColumns = requestedRows(:,opt.columns);
% Convert row/column slice of table to array? 
if opt.arr
    requestedRowsAndColumns = ...
        table2array(requestedRowsAndColumns);
end
