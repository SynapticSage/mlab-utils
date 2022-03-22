function matches = findRowByColumn(obj, columns, value)
% Finds row of data by column of table
%
% columns : n x m string or cellstr each n is a level deep, each
% m is an additional column value : value to find either a table
% obj for that row/col set or a value that would match a single
% column

matches = true(height(obj), 1);

for column = columns
    OBJ = obj;
    while numel(column) > 0
        OBJ = OBJ.(column);
        column(1) = [];
    end
    matches = matches & OBJ == value;
end
