function [DJF, MAM, JJA, SON] = get_seasons(A)

% INPUT
%   A : 3 dimensional matrix (i.e. array) [x, y, time] where x and y are 
%   grid indices and time is in MONTHLY RESOLUTION and A starts in JANUARY / JANVIER / Ayy an-N?r ~*~:)_
% OUTPUT
%   [DJF, MAM, JJA, SON] are the separated seasonal components of A
%   segmented along the third dimension

uo = 'UniformOutput';
midx = 0:12:1812;

djf = cell2mat(arrayfun(@(x) x + (0:2), midx, uo, false));
mam = cell2mat(arrayfun(@(x) x + (3:5), midx, uo, false));
jja = cell2mat(arrayfun(@(x) x + (6:8), midx, uo, false));
son = cell2mat(arrayfun(@(x) x + (9:11), midx, uo, false));

badidx = @(x) x < 1 | x > size(A,3);
djf(badidx(djf)) = [];
mam(badidx(mam)) = [];
jja(badidx(jja)) = [];
son(badidx(son)) = [];

DJF = A(:,:,djf);
MAM = A(:,:,mam);
JJA = A(:,:,jja);
SON = A(:,:,son);

end