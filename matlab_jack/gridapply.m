function Y = gridapply(A, B, distfun)

ncells  = numel(A(:,:,1));
A_vec   = reshape(A, [ncells,1,size(A,3)]);
B_vec   = reshape(B, [ncells,1,size(B,3)]);
results = cell(ncells,1);

for i = 1:ncells
    ai = A_vec(i,1,:);
    bi = B_vec(i,1,:);
    ai = reshape(ai, [numel(ai),1]);
    bi = reshape(bi, [numel(bi),1]);
    yi = distfun(ai,bi);
    results{i} = yi;

end

Y = reshape(cell2mat(results(:,1)), [size(A,1), size(A,2), numel(results{1,1})]);

end