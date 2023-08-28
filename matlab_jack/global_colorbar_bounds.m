function [minval, maxval] = global_colorbar_bounds(C)

% computes the global extreme (min, max) for MULTIPLE 2D matrices. This
% helper function is for plotting purposes, specifically, to produce
% colorbars with the same scale/limits across different figures

% input C is an N-x-1 cell array with each cell containing a 2D array

% output is two scalars, the min and max values in all arrays in C
narr = length(C);
[cmin, cmax] = deal(zeros(narr,1));

for ic = 1:narr
    cmin(ic) = min(min(C{ic}));
    cmax(ic) = max(max(C{ic}));
end

minval = min(cmin);
maxval = max(cmax);

end