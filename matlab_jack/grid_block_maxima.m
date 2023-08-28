function maxima = grid_block_maxima(A, blockSize)

ncells = numel(A(:,:,1));
A_vec  = reshape(A, [ncells,1,size(A,3)]);
maxcells = cell(ncells, 1);
for i = 1:ncells
    tsi = A_vec(i,1,:);
    tsi = reshape(tsi, [numel(tsi),1]);
    maxi = blockMaxima(tsi, blockSize);
    maxcells{i} = maxi;
end

maxima = zeros(ncells, 1, numel(maxcells{1}));

for j = 1:ncells
    mcj = maxcells{j};
    maxima(j,1,:) = reshape(mcj, [1,1,numel(mcj)]);
end

maxima = reshape(maxima, [size(A,1), size(A,2), size(maxima,3)]);

end