function animate_series(ts, figname, dt)

if nargin > 1
    figure('Name', figname); hold on
else
    figure; hold on
end

if nargin < 3
    dt = 0.1;
end
colormap(jet)
for i = 1:size(ts,3)
    
    pause(dt)
    imagesc(ts(:,:,i))
    colorbar
    
end

end