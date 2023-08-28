function bmax = blockMaxima(x, blockSize)

% INPUT
%   x - [n x 1 array] data to compute block maxima for
%   blockSize - [scalar] size of blocks in number of timesteps
% OUTPUT
%   bmax - [n-blockSize x 1 array] of maxima in each block in x

if size(x,1) == 1 && size(x,2) == 1 && size(x,3) > 1
    x = reshape(x, [numel(x),1]);
end

nblocks = floor(length(x)/blockSize);

bmax = zeros(nblocks,1);
for i = 1:nblocks
    if i == 1
        block = x(1:blockSize);
    else
        block = x(((i-1)*blockSize):(i*blockSize)-1);  
    end
    xmax = max(block);
    bmax(i) = xmax;
end

end