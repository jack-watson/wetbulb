function JJA = get_JJA_dailyres(A)

% INPUT
%   A : 3 dimensional matrix (i.e. array) [x, y, time] where x and y are 
%   grid indices and time is in DAILY RESOLUTION and A starts in JANUARY / JANVIER / Ayy an-N?r ~*~:)_
% OUTPUT
%   [DJF, MAM, JJA, SON] are the separated seasonal components of A
%   segmented along the third dimension

uo = 'UniformOutput';
midx = 0:365:size(A,3);

%djf = cell2mat(arrayfun(@(x) x + (0:88), midx, uo, false));
%mam = cell2mat(arrayfun(@(x) x + (89:189), midx, uo, false));
jja = cell2mat(arrayfun(@(x) x + (152:241), midx, uo, false));
%son = cell2mat(arrayfun(@(x) x + (281:360), midx, uo, false));

badidx = @(x) x < 1 | x > size(A,3);
%djf(badidx(djf)) = [];
%mam(badidx(mam)) = [];
jja(badidx(jja)) = [];
%son(badidx(son)) = [];

%DJF = A(:,:,djf);
%MAM = A(:,:,mam);
JJA = A(:,:,jja);
%SON = A(:,:,son);

end