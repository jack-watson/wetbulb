function A_star = regridder(A, B, interp_method)

% Interpolates A (target) to resolution of B

if nargin < 3
    interp_method = 'bicubic';
end

dims_B = size(B);
Bxy = dims_B(1:2);

A_star = imresize(A, Bxy, interp_method);

end