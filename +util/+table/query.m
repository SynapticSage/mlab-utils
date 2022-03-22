function [requestedRowsAndColumns, requestedRows, logicalRows] = query(T, queryStr, varargin)
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
%   first Optional input will be a column or column of T to extract -- defaults too all columns
%   
%   subsequet keyword-arg pairs below
%   
%   arr : default true
%       return table2array(requestedRowsAndColumns)? 
%

ip = inputParser;
ip.addOptional('columns',':', @(x) true);
ip.addParameter('debug', false)
ip.addParameter('arr',false); % convert to array?
ip.addParameter('recurseStruct',true); % If T is a struct, recurse?
ip.parse(varargin{:});
Opt = ip.Results;

if Opt.recurseStruct && isstruct(T)
    for field = string(fieldnames(T))'
        requestedRowsAndColumns.(field) = util.table.query(T.(field), queryStr, Opt.columns, Opt);
    end
elseif istable(T)
    % ------MEAT AND POTATOES ------------------------------------
    % Get rows user requests
    logicalRows = util.table.query_logical(T, queryStr, Opt);
    requestedRows = T(logicalRows,:);
    % Get columns of rows user requests
    requestedRowsAndColumns = requestedRows(:,Opt.columns);

    % Convert row/column slice of table to array? 
    if Opt.arr
        requestedRowsAndColumns = ...
            table2array(requestedRowsAndColumns);
    end
    % ------------------------------------------------------------
else
    requestedRowsAndColumns = [];
end

