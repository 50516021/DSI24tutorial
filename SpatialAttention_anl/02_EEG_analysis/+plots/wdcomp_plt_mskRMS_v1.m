% Wet-Dry comparison - Masker RMS line plot v1 % 
% - calculate RMS/crestfactor for Masker onsets for EEG gear comparison 
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250612 Masker RMS line plot for EEG Wet-Dry gear comparison
% 20250618 CF -> RMS correction


function wdcomp_plt_mskRMS_v1(plot_data, plot_params)

%% parameters

% extend from plot_data
rmsMsk_BS_plot = plot_data.rmsMsk_BS_plot;
rmsMsk_DS_plot = plot_data.rmsMsk_DS_plot;

% extend from plot_params 
varIter      = plot_params.varIter;
numIter      = plot_params.numIter;
maxrange     = plot_params.maxrange;
baserange    = plot_params.baserange;
coSBS        = plot_params.coSBS;
coSDS        = plot_params.coSDS;
numCh        = plot_params.numCh;
numSPTvar    = plot_params.numSPTvar;
numdev       = plot_params.numdev;
dirname_fig  = plot_params.dirname_fig;
sublist_name      = plot_params.sublist_name;


% check variables
disp('--- plot_data ---');
whos rmsMsk_BS rmsMsk_DS rmsMsk_BS_plot rmsMsk_DS_plot SE_rmsMsk_BS SE_rmsMsk_DS

disp('--- plot_params ---');
whos varIter numIter maxrange baserange coSBS coSDS numCh numSPTvar numIterBS numIterDS numdev dirname_fig sublist_name devshort devlong Snum SNRs Spat Chs Hotch fsEEG calc_range namekey filesubject subList datanum

%% make RMS Masker figure

%average of all pattern (channel/spatial pattern)
rmsMsk_BS_aveplot = mean(squeeze(mean(rmsMsk_BS_plot,2)),2); %rmsMsk_BS_plot(iterationVari, channel, Spatial Pattern)
rmsMsk_DS_aveplot = mean(squeeze(mean(rmsMsk_DS_plot,2)),2);

figure('Position', [100 100 700 700]);

type = {'FRONT-Fz','BACK-Fz', 'FRONT-Cz','BACK-Cz', 'Average'};
yscale = [2 6];
yname = 'RMS';
xname = 'iteration';
% col = {'b','r'};

for Ndev = 1:numdev
    subplot(1,2, Ndev);
    for i = 1:numCh %plot BioSemi
        for j=1:numSPTvar
            if Ndev == 1
                plot(squeeze(rmsMsk_BS_plot(:,i,j))); hold on;
            elseif Ndev == 2
                plot(squeeze(rmsMsk_DS_plot(:,i,j))); hold on;
            end
        end
    end
    if Ndev == 1
        plot(rmsMsk_BS_aveplot, 'LineWidth',3);
        title(['Biosemi (' sprintf('N=%i)',coSBS)]);
    elseif Ndev == 2
        plot(rmsMsk_DS_aveplot, 'LineWidth',3);
        title(['DSI-24  (' sprintf('N=%i)',coSDS)]);  
    end

    legend(type,'Location','southeast');
    ylim(yscale); 
    xticks(1:numIter)
    xticklabels(varIter)
    xlabel(xname);
    ylabel(yname);
    grid on;
end

figuretitle = sprintf('RMS of Masker EEG from %d - %d ms / %d - %d ms',maxrange*1000, baserange*1000);
sgtitle(figuretitle)
pdfname = [dirname_fig, 'RMS_Msk_', sublist_name, sprintf('_%d%d_%d%d',maxrange*1000, baserange*1000), '.pdf'];
print(pdfname,'-dpdf');
