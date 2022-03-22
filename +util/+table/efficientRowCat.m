function T = efficientRowCat(T)
% function T = efficientRowCat(T)
% Takes a cell of tables and more memory
% efficiently concatonates them. Useful for GPU
% tables eg where one has limited resource.

for i = 2:numel(T)
    T{1} = [T{1}; T{i}];
    T{i} = [];
end

T = T{1};
