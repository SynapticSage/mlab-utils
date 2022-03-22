function T = fastRowCat(T)
% function T = efficientRowCat(T)
% Takes a cell of tables and more memory
% efficiently concatonates them. Useful for GPU
% tables eg where one has limited resource.

T = cat(1, T{:});
