function result = stringify(result, varargin)

ip = inputParser;
ip.addOptional('fields',[]);
ip.parse(varargin{:});
opt = ip.Results;

if isempty(opt.fields)
    opt.fields = string(fieldnames(result(1)));
else
    opt.fields = string(opt.fields);
end

for i = 1:numel(result)
for field = opt.fields(:)'
    
    if ischar(result(i).(field)) || iscellstr(result(i).(field))
        result(i).(field) = string(result(i).(field));
    end
    
end
end
