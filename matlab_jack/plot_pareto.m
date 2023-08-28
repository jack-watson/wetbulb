function plot_pareto(params1, params2)

figure
subplot(2,1,1); hold on; grid on
plot(params1(:,1),'LineWidth', 2)
plot(params2(:,1), 'LineWidth', 2)
plot(movmean(params1(:,1),50), 'LineWidth',2)
plot(movmean(params2(:,1),50), 'LineWidth',2)
%scatter(lmax6klocs, lmax6k,'filled')
%scatter(lmax5klocs, lmax5k, 'filled')
legend({'CMIP6','CMIP5', 'CMIP6 moving mean', 'CMIP5 moving mean'})
title('Shape param (k)')
%xlim([0,1800])
%ylim([0, 0.6])

subplot(2,1,2); hold on; grid on
plot(params1(:,2),'LineWidth', 2)
plot(params2(:,2),'LineWidth', 2)
plot(movmean(params1(:,2),50), 'LineWidth',2)
plot(movmean(params2(:,2),50), 'LineWidth',2)
legend({'CMIP6','CMIP5', 'CMIP6 moving mean', 'CMIP5 moving mean'})
title('Scale param (sigma)')
% ylim([1e-4, 2.5e-4])
% xlim([0,1800])

end