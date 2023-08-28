function s = compareHists(x1,x2)
% s = compareHists(h1,h2)
%       returns a histogram similarity in the range 0..1
%
% Compares 2 normalised histograms using the Bhattacharyya coefficient.
% Assumes that sum(x1) == sum(x2) == 1

s = sum(sum(sqrt(x1).*sqrt(x2)));

end