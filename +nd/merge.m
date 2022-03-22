function A = merge(A,B)
% Merge two structs with different fields but the same ND shape into one

assert(all(size(A)==size(B)));

indices = nd.indicesMatrixForm(A);
for index = indices'
    I = num2cell(index);
    for field = string(fieldnames(B(I{:})))'
        if  ~isfield(A(I{:}),field)
            A(I{:}).(field) = B(I{:}).(field);
        end
    end
end
