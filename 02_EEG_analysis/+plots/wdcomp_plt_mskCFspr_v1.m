% Wet-Dry comparison - Make Crest Factor Masker figure (separate) v1 % 
% - calculate RMS/crestfactor for Masker onsets for EEG gear comparison
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250612 Make Crest Factor Masker figure (separate) for EEG Wet-Dry gear comparison
% 20250618 moved CF calculation to the main script

function wdcomp_plt_mskCFspr_v1(plot_data, plot_params)

%% parameters


% extend from plot_data
CF_Msk_BS_plot = plot_data.CF_Msk_BS_plot;
CF_Msk_DS_plot = plot_data.CF_Msk_DS_plot;


% extend from plot_params 
varIter      = plot_params.varIter;
numIter      = plot_params.numIter;
maxrange     = plot_params.maxrange;
baserange    = plot_params.baserange;
coSBS        = plot_params.coSBS;
coSDS        = plot_params.coSDS;
numCh        = plot_params.numCh;
numdev       = plot_params.numdev;
numSPTvar    = plot_params.numSPTvar;
dirname_fig  = plot_params.dirname_fig;
sublist_name      = plot_params.sublist_name;
type         = plot_params.type;

% check variables
disp('--- plot_data ---');
whos rmsMsk_BS rmsMsk_DS rmsMsk_BS_plot rmsMsk_DS_plot SE_rmsMsk_BS SE_rmsMsk_DS

disp('--- plot_params ---');
whos varIter numIter maxrange baserange coSBS coSDS numCh numSPTvar numIterBS numIterDS numdev dirname_fig sublist_name devshort devlong Snum SNRs Spat Chs Hotch fsEEG calc_range namekey filesubject subList datanum

%% make Crest Factor Masker figure (separate)

%average of all patterns (channel/spatial pattern)
CF_MskBS_aveplot = mean(squeeze(mean(CF_Msk_BS_plot,2)),2); %rmsMsk_BS_plot(iterationVari, channel, Spatial Pattern)
CF_MskDS_aveplot = mean(squeeze(mean(CF_Msk_DS_plot,2)),2);

figure('Position', [100 100 700 700]);

yscale = [1.9 2.3];
yname = 'Crest Factor';
xname = 'Iteration';
% col = {'b','r'};

for Ndev = 1:numdev
    subplot(1,2, Ndev);
    for i = 1:numCh %plot BioSemi
        for j=1:numSPTvar
            if Ndev == 1
                plot(squeeze(CF_Msk_BS_plot(:,i,j))); hold on;
            elseif Ndev == 2
                plot(squeeze(CF_Msk_DS_plot(:,i,j))); hold on;
            end
        end
    end
    if Ndev == 1
        CF_Msk_BS_aveplot = squeeze(mean(CF_Msk_BS_plot, [2,3]));
        plot(CF_Msk_BS_aveplot, 'LineWidth',3);
        title(['Biosemi (' sprintf('N=%i)',coSBS)]);
    elseif Ndev == 2
        CF_Msk_DS_aveplot = squeeze(mean(CF_Msk_DS_plot, [2,3]));
        plot(CF_Msk_DS_aveplot, 'LineWidth',3);
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

figuretitle = sprintf('Crest Factor of Masker EEG from %d - %d ms (peak) / %d - %d ms',maxrange*1000, baserange*1000);
sgtitle(figuretitle)
pdfname = [dirname_fig, 'CF_Msk_SNR_', sublist_name, sprintf('_%d%d_%d%d',maxrange*1000, baserange*1000), '.pdf'];
print(pdfname,'-dpdf');
