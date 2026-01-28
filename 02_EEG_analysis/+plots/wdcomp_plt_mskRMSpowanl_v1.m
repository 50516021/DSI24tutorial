% Wet-Dry comparison - power analysis - various iterations v1 % 
% - calculate RMS/crestfactor for Masker onsets for EEG gear comparison
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250612 power analysis - various iterations for EEG Wet-Dry gear comparison
% 20250618 CF -> RMS correction

function wdcomp_plt_mskRMSpowanl_v1(plot_data, plot_params)

%% parameters


% extend from plot_data
rmsMsk_BS_plot = plot_data.rmsMsk_BS_plot;
rmsMsk_DS_plot = plot_data.rmsMsk_DS_plot;
SE_rmsMsk_BS   = plot_data.SE_rmsMsk_BS;

% extend from plot_params 
varIter      = plot_params.varIter;
numIter      = plot_params.numIter;
maxrange     = plot_params.maxrange;
baserange    = plot_params.baserange;
numCh        = plot_params.numCh;
numSPTvar    = plot_params.numSPTvar;
dirname_fig  = plot_params.dirname_fig;
Snum         = plot_params.Snum;
sublist_name      = plot_params.sublist_name;
type         = plot_params.type;

% check variables
disp('--- plot_data ---');
whos rmsMsk_BS_plot rmsMsk_DS_plot SE_rmsMsk_BS

disp('--- plot_params ---');
whos varIter numIter maxrange baserange numCh numSPTvar dirname_fig sublist_name;

%% power analysis - various iterations

nn = 1:50; %sample variation 

for iterNo = 1:numIter %iteration variation (small to big)
    for i = 1:numCh %plot BioSemi
        for j=1:numSPTvar
            pwroutIter(:,i,j,iterNo) = sampsizepwr('t2',[rmsMsk_BS_plot(iterNo,i,j) SE_rmsMsk_BS(iterNo,i,j)], rmsMsk_DS_plot(iterNo,i,j),[],nn);
        end
    end    

    figure;
    
    for i = 1:numCh %plot BioSemi
        for j=1:numSPTvar
            plot(nn,squeeze(pwroutIter(:,i,j,iterNo))); hold on;
        end
    end

    xline(10); hold on;
    yline([0.8, 0.9]);
    legend(type(1:end-1),'Location','southeast')
    title(sprintf('Power vs Sample Size from %d subjects %d iterations', Snum, varIter(iterNo)))
    xlabel('Sample Size')
    ylim([0,1.1]);
    ylabel('Power')

    pdfname = sprintf('%spow_anaysis_%s_BS-DS_%diter.pdf', dirname_fig, sublist_name, varIter(iterNo));
    saveas(gcf, pdfname)

end