function plot_pareto_ensemble(params1, params2)

% params1 = reshape(params1, [numel(params1),1]);
% params2 = reshape(params2, [numel(params2),1]);

figure('Name', 'K')
idx = 1;
for i = 1:4
    for j = 1:8
        subplot(4,8,idx); hold on; grid on
        pi1 = params1{i,j};
        pi2 = params2{i,j};
        plot(pi1(:,1), 'LineWidth', 0.5)
        plot(pi2(:,1), 'LineWidth', 0.5)
        plot(movmean(pi1(:,1),50), 'LineWidth', 2)
        plot(movmean(pi2(:,1),50),'LineWidth',2)
        title(['Shape param (k) ' num2str(i) ',' num2str(j)])
        idx = idx + 1;
    end
    %idx = idx + 1;
end

figure('Name', 'sigma')
idx = 1;
for i = 1:4
    for j = 1:8
        subplot(4,8,idx); hold on; grid on
        pi1 = params1{i,j};
        pi2 = params2{i,j};
        plot(pi1(:,2), 'LineWidth', 0.5)
        plot(pi2(:,2), 'LineWidth', 0.5)
        plot(movmean(pi1(:,2),50), 'LineWidth', 2)
        plot(movmean(pi2(:,2),50),'LineWidth',2)
        title(['Scale param (sigma)' num2str(i) ',' num2str(j)])
        idx = idx + 1;
    end
    %idx = idx + 1;
end

% figure
% subplot(2,1,1); hold on; grid on
% for i = 1:numel(params1)
%     pi1 = params1{i};
%     pi2 = params2{i};
%     plot(pi1(:,1), 'r', 'LineWidth', 1)
%     plot(pi2(:,1), 'b', 'LineWidth', 1)
%     %plot(movmean(pi(:,1),50), 'LineWidth',2)
%     title('Shape param (k)')
% end
% %xlim([0,1800])
% %ylim([0, 0.6])
% 
% subplot(2,1,2); hold on; grid on
% for i = 1:numel(params1)
%     pi1 = params1{i};
%     pi2 = params2{i};
%     plot(pi1(:,2), 'r', 'LineWidth',1)
%     plot(pi2(:,2), 'b', 'LineWidth',1)
%     %plot(movmean(pi(:,2),50), 'LineWidth',2)
%     title('Scale param (sigma)')
% end
% % ylim([1e-4, 2.5e-4])
% % xlim([0,1800])

end

