% Wet-Dry comparison - save the data for ANOVA (Masker) v1 % 
% - calculate RMS/crestfactor for Masker onsets for EEG gear comparison
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250612 save the data for ANOVA (Masker) for EEG Wet-Dry gear comparison
% 20250618 deleted averaging, organized the process

function wdcomp_plt_mskCFANOAsave_v1(plot_data, plot_params)

%% parameters


% extend from plot_data
rmsMsk_BS = plot_data.rmsMsk_BS;
rmsMsk_DS = plot_data.rmsMsk_DS;
CF_Msk_BS = plot_data.CF_Msk_BS;
CF_Msk_DS = plot_data.CF_Msk_DS;

% extend from plot_params 
subList      = plot_params.subList; % subject list
varIter      = plot_params.varIter;
numIter      = plot_params.numIter;
maxrange     = plot_params.maxrange;
baserange    = plot_params.baserange;
calc_range   = plot_params.calc_range;
numCh        = plot_params.numCh;
numdev       = plot_params.numdev;
numSPTvar    = plot_params.numSPTvar;
dirname_fig  = plot_params.dirname_fig;
Snum         = plot_params.Snum;
sublist_name = plot_params.sublist_name;
Spat        = plot_params.Spat;
Chs         = plot_params.Chs;
ANOVA_dir  = plot_params.ANOVA_dir;


% check variables
disp('--- plot_data ---');
whos EEG_Msk_BS EEG_Msk_DS

disp('--- plot_params ---');
whos varIter numIter maxrange baserange coSBS coSDS numCh numSPTvar numIterBS numIterDS numdev dirname_fig sublist_name devshort devlong Snum SNRs Spat Chs Hotch fsEEG calc_range namekey filesubject subList datanum

%% save the data for ANOVA (Masker)

%Index: rmsMsk_BS([iterationVari], [subject(1:10)], [channel (only hot)], [Spatial Pattern])

for j =1:numCh %channel (generate numChs of files)
    co_BS = 0; %counter for BioSemi
    co_DS = 0; %counter for DSI-24
    co = 0; %counter
    for m =1:size(subList,1) %subject index of subList
        subid_num = subList.subID(m);
        dev       = subList.device(m); 
        if dev == "BS" %BioSemi
            co_BS = co_BS + 1; 
        elseif dev == "DSI" %DSI-24
            co_DS = co_DS + 1;
        end
        for i =1:numSPTvar %Spatial Pattern
            for k = 1:numIter %iteration 
                co=co+1;
                subject_Msk(co) = strcat("s", num2str(subid_num));
                dev_Msk(co)     = dev;
                numIter_Msk(co) = varIter(k);
                SPAt_Msk(co)    = Spat(i);
                if dev_Msk(co) == "BS" %BioSemi
                    data_RMS_Msk(co) = rmsMsk_BS(k, co_BS, j, i);
                    data_CF_Msk(co)  = CF_Msk_BS(k, co_BS, j, i);
                elseif dev_Msk(co) == "DSI" %DSI-24
                    data_RMS_Msk(co) = rmsMsk_DS(k, co_DS, j, i);
                    data_CF_Msk(co)  = CF_Msk_DS(k, co_DS, j, i);
                end
            end
        end
    end
    
    % % save 2 way data
    % dataTable_RMS = table(subject_Msk', dev_Msk', SPAt_Msk', data_RMS_Msk');
    % dataTable_RMS.Properties.VariableNames = {'subject', 'device', 'SPAt', 'RMS'};
    % ANOVAfilename_RMS = strcat('ANOVAsheet_wdcomp_Msk_RMS_', sublist_name, '_', Chs(j), calc_range, '2way.csv');
    % writetable(dataTable_RMS, strcat(ANOVA_dir, ANOVAfilename_RMS));
    % 
    % dataTable_CF = table(subject_Msk', dev_Msk', SPAt_Msk', data_CF_Msk');
    % dataTable_CF.Properties.VariableNames = {'subject', 'device', 'SPAt', 'CF'};
    % ANOVAfilename_CF = strcat('ANOVAsheet_wdcomp_Msk_CF_', sublist_name, '_', Chs(j), calc_range, '2way.csv');
    % writetable(dataTable_CF, strcat(ANOVA_dir, ANOVAfilename_CF));

    % save 3 way data
    dataTable_RMS = table(subject_Msk', numIter_Msk', dev_Msk', SPAt_Msk', data_RMS_Msk');
    dataTable_RMS.Properties.VariableNames = {'subject', 'numIter', 'device', 'SPAt', 'RMS'};
    ANOVAfilename_RMS = strcat('ANOVAsheet_wdcomp_Msk_RMS_', sublist_name, '_', Chs(j), calc_range, '3way.csv');
    writetable(dataTable_RMS, strcat(ANOVA_dir, ANOVAfilename_RMS));

    dataTable_CF = table(subject_Msk', numIter_Msk', dev_Msk', SPAt_Msk', data_CF_Msk');
    dataTable_CF.Properties.VariableNames = {'subject', 'numIter', 'device', 'SPAt', 'CF'};
    ANOVAfilename_CF = strcat('ANOVAsheet_wdcomp_Msk_CF_', sublist_name, '_', Chs(j), calc_range, '3way.csv');
    writetable(dataTable_CF, strcat(ANOVA_dir, ANOVAfilename_CF));

end