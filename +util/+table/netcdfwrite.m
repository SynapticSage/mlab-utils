function netcdfwrite(T, filename)

T = util.table.castefficient(T);
fields = string(T.Properties.VariableNames);
if exist(filename, 'file')
    delete(filename);
end

Dimensions = {'sample', height(T), 'column', 1};
for variable = progress(fields(:)')
    nccreate(filename, variable, ...
        'Dimensions', Dimensions,...
        'Format', 'netcdf4',...
        'ChunkSize', [100000, 1],...
        'DeflateLevel', 8,...
        'DataType', class(T.(variable)));
    ncwrite(filename, variable, T.(variable));
end

clear all % doing this because I'm losing some memory for an unknown reason
