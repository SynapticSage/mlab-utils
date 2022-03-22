function [sequence,time] = padB(sequence, offset)

if offset < 0
    sequence = [ zeros(1,abs(offset)), sequence(:)'];
    %sequence = [ sequence(:)', zeros(1,abs(offset))];
elseif offset > 0
    %sequence = [zeros(1,abs(offset)), sequence(:)'];
    sequence = [ sequence(:)', zeros(1,abs(offset))];
end
