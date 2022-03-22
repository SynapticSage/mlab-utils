function [columns] = getDataVars(T, exc, varargin)
% Like query.getIndex, but instead of returning index variables,
% returns all data/result-related varialbes in a table. Modulus
% an exclusion list.

data_var = ["rrDim", "percMax_rrDim", "full_model_performance"];
data_var = setdiff(data_var, exc);
columns  = data_var(ismember(data_var, T.Properties.VariableNames));
