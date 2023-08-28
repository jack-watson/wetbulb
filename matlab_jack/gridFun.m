function Y = gridFun(x, fun, funArgs)

% INPUT
%   x - [n x m x t array] gridded matrix to be operated on
%   fun - [function handle] to apply along third dimension of matrix
%   funArgs - [1 x n cell array] containing any additional inputs to fun
% OUTPUT
%   Y - [n x m cell array] containing output of fun for each tile in
%   gridded matrix x

ntiles = numel(x(:,:,1)); % number of grid tiles

xr = reshape(x, [ntiles,1,size(x,3)]); % reshape so all grid tiles are along the first dimension
Y = cell(ntiles, 1); % preallocate array of results
for i = 1:ntiles
    xi = xr(i,1,:);
    if nargin > 2
        y = fun(xi,funArgs{:});
    elseif nargin < 3
        y = fun(xi);
    end
    Y{i} = y;
end

Y = reshape(Y, [size(x,1), size(x,2)]);

end