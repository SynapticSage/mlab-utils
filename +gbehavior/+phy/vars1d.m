function vars = vars1d(beh)


vars = setdiff(string(beh.Properties.VariableNames), ["day", "time"]);
