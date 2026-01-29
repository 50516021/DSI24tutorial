% Wet-Dry comparison - Masker Crest Factor errorbar plot (overlay - individual) v1 % 
% - calculate RMS/crestfactor for Masker onsets for EEG gear comparison
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250612 Masker Crest Factor errorbar plot (overlay - individual) for EEG Wet-Dry gear comparison
% 20250618 CF -> RMS correction

function wdcomp_plt_mskRMSovl_indiv_v1(plot_data, plot_params)

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


%% Masker RMS errorbar plot (overlay - individual)

% figure('Position', [100 100 500 500]);
leg_BF = ["Biosemi Front", "DSI-24 Front", "Biosemi Back", "DSI-24 Back"];
yscale = [0.5 6.5];
yname = 'RMS';
xname = 'Iteration';
col = ['b','r'];
objects = ["-", "--"];
x_erbr = 1:numIter; %x values of the plot
offset_initial = -0.3; %errorbar offset 
offset_gap = 0.2; %errorbar offset 
lbl_fontsize   = 30;
lgnd_fontsize  = 30;
ticks_fontsize = 30;

co = 0;

for i = 1:numCh
    co = co + 1;
   fig = figure('Position', [100 100 500 300]);

    co_ofst = 0;
    for j=1:numSPTvar
        offset_temp = offset_initial+offset_gap*co_ofst;
        er_plot = errorbar(x_erbr+offset_temp, squeeze(rmsMsk_BS_plot(:,i,j)),squeeze(SE_rmsMsk_BS(:,i,j)),objects(j),'Color',col(1)); hold on; %plot BioSemi   
        er_plot.CapSize = 15;
        co_ofst = co_ofst + 1;
        
        offset_temp = offset_initial+offset_gap*co_ofst;
        er_plot = errorbar(x_erbr+offset_temp, squeeze(rmsMsk_DS_plot(:,i,j)),squeeze(SE_rmsMsk_DS(:,i,j)),objects(j),'Color',col(2)); hold on; %plot DSI-24
        er_plot.CapSize = 7;
        co_ofst = co_ofst + 1;
    end


    % title(sprintf('%s', Chs(i)), 'FontSize', 18);  % Set title font size
    lgd = legend(leg_BF, 'Location', 'southeast');  % Legend with font size
    set(lgd, 'FontSize', lgnd_fontsize);            % Set legend font size

    xticks(1:numIter);
    xticklabels(varIter);
    
    xlabel(xname, 'FontSize', lbl_fontsize);
    ylabel(yname, 'FontSize', lbl_fontsize);

    set(gca, 'FontSize', ticks_fontsize); % Set tick label font size

    grid on;
    axis padded    
    ylim(yscale); 

    % Set the figure size and paper size for saving
    set(fig, 'PaperUnits', 'inches');
    set(fig, 'PaperPosition', [0 0 10 8]); % 10x8 inches
    set(fig, 'PaperSize', [10 8]);

    figuretitle = sprintf('RMS of Masker EEG (extracted) from %d - %d ms / %d - %d ms',maxrange*1000, baserange*1000);
    % sgtitle(figuretitle)
    pdfname = strcat(dirname_fig, 'RMS(extract)_Msk_ovl_', Chs(i), '_', sublist_name, sprintf('_%d%d_%d%d',maxrange*1000, baserange*1000), '.pdf');
    saveas(gcf, pdfname)

end
