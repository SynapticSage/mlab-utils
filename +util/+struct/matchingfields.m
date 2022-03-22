function [matchingfields, answers] = matchingfields(S, varargin)
% matchingfields

ip = inputParser;
ip.addParameter('logic', 'or'); % how to handle condition lists
ip.addParameter('valueConditions', {}); % 
ip.addParameter('keyConditions', {}); % 
ip.parse(varargin{:})
Opt = ip.Results;

if isa(Opt.valueConditions, 'function_handle')
    Opt.valueConditions = {Opt.valueConditions};
end
if isa(Opt.keyConditions, 'function_handle')
    Opt.keyConditions = {Opt.keyConditions};
end

if ~isempty(Opt.valueConditions)
    conditions = struct();
    for c = 1:numel(Opt.valueConditions)
        conditions(c).type = 'value';
        conditions(c).val  = Opt.valueConditions{c};
    end
    C = numel(conditions);
else
    conditions = struct();
    C = 0;
end
for c = 1:numel(Opt.keyConditions)
    conditions(C+c).type = 'key';
    conditions(C+c).val  = Opt.keyConditions{c};
end

fields  = string(fieldnames(S))';
answers = false(numel(fields), numel(conditions));

for f = 1:numel(fields)
    for c = 1:numel(conditions)
        switch conditions(c).type
            case 'key'
                answers(f, c) = conditions(c).val(fields(f));
            case 'value'
                answers(f, c) = conditions(c).val(S.(fields(f)));
        end
    end
end

switch Opt.logic
    case 'and'
        answers = prod(answers, 2) >= 1;
    case 'or'
        answers = sum(answers, 2) >= 1;
    otherwise
        error("Bad input")
end

matchingfields = fields(answers);
