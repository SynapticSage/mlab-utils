function T = categorical2string(T)

for field = string(T.Properties.VariableNames)
    if iscategorical(T.(field))
        T.(field) = string(T.(field));
    end
end
