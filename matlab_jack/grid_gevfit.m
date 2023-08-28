function [paramEsts,paramCIs, dnc] = grid_gevfit(A)

% dnc is 2D logical matrix indicating if that cell's estimate did (1) or
% did not (0) converge

ncells  = numel(A(:,:,1));
A_vec   = reshape(A, [ncells,1,size(A,3)]);
results = cell(ncells, 2);
dnc = false(ncells,1);

for i = 1:ncells
    lastwarn('')
    tsi = A_vec(i,1,:);
    tsi = reshape(tsi, [numel(tsi),1]);
    [esti, CIi] = gevfit(tsi);
    results{i,1} = esti;
    results{i,2} = CIi;
    dnc(i) = isempty(lastwarn());
    lastwarn('')
end

paramEsts = reshape(cell2mat(results(:,1)), [size(A,1), size(A,2), numel(results{1,1})]);
paramCIs = reshape(cell2mat(results(:,2)), [size(A,1), size(A,2), numel(results{1,2})]);
dnc = reshape(dnc, [size(A,1), size(A,2)]);

end