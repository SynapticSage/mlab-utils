function sequence = padA(sequence,offset)

if offset < 0
    sequence = [zeros(1,abs(offset)), sequence(:)'];
elseif offset > 0
    sequence = [sequence(:)', zeros(1,abs(offset))];
end
