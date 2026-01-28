% Wet-Dry comparison - Masker RMS errorbar plot (2 by 2) v1 % 
% - calculate RMS/crestfactor for Masker onsets for EEG gear comparison
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250612 Masker RMS errorbar plot (2 by 2) for EEG Wet-Dry gear comparison
% 20250618 CF -> RMS correction

function wdcomp_plt_mskRMS2b2_v1(plot_data, plot_params)

%% parameters


% extend from plot_data
rmsMsk_BS_plot = plot_data.rmsMsk_BS_plot;
rmsMsk_DS_plot = plot_data.rmsMsk_DS_plot;
SE_rmsMsk_BS   = plot_data.SE_rmsMsk_BS;
SE_rmsMsk_DS   = plot_data.SE_rmsMsk_DS;

% extend from plot_params 
varIter      = plot_params.varIter;
numIter      = plot_params.numIter;
maxrange     = plot_params.maxrange;
baserange    = plot_params.baserange;
numCh        = plot_params.numCh;
numSPTvar    = plot_params.numSPTvar;
dirname_fig  = plot_params.dirname_fig;
sublist_name      = plot_params.sublist_name;
devlong      = plot_params.devlong;
Chs          = plot_params.Chs;
Spat         = plot_params.Spat;

% check variables
disp('--- plot_data ---');
whos rmsMsk_BS rmsMsk_DS rmsMsk_BS_plot rmsMsk_DS_plot SE_rmsMsk_BS SE_rmsMsk_DS

disp('--- plot_params ---');
whos varIter numIter maxrange baserange coSBS coSDS numCh numSPTvar numIterBS numIterDS numdev dirname_fig sublist_name devshort devlong Snum SNRs Spat Chs Hotch fsEEG calc_range namekey filesubject subList datanum

%% Masker RMS errorbar plot (2 by 2)

% figure('Position', [100 100 500 500]);
figure;

yscale = [1 7];
yname = 'Crest Factor';
xname = 'Iteration';
col = ['b','r'];
objects = ["-", "-"];

co = 0;

for i = 1:numCh
    for j=1:numSPTvar
        co = co + 1;
        subplot(numCh,numSPTvar,co)

        er_plot = errorbar(squeeze(rmsMsk_BS_plot(:,i,j)),squeeze(SE_rmsMsk_BS(:,i,j)),objects(i),'Color',col(1)); hold on; %plot BioSemi   
        er_plot.CapSize = 15;
    
        er_plot = errorbar(squeeze(rmsMsk_DS_plot(:,i,j)),squeeze(SE_rmsMsk_DS(:,i,j)),objects(i),'Color',col(2)); hold on; %plot DSI-24
        er_plot.CapSize = 7;
    
        title(sprintf('%s %s',Chs(i), Spat(j)))
        legend(devlong,'Location','southeast');
        ylim(yscale); 
        xticks(1:numIter)
        xticklabels(varIter)
        xlabel(xname);
        ylabel(yname);
        grid on;
        axis padded
    end
end

figuretitle = sprintf('RMS of Masker EEG (extracted) from %d - %d ms / %d - %d ms',maxrange*1000, baserange*1000);
sgtitle(figuretitle)
pdfname = [dirname_fig, 'RMS(extract)_Msk_', sublist_name, sprintf('_%d%d_%d%d',maxrange*1000, baserange*1000), '.pdf'];
saveas(gcf, pdfname)