# BehavioralAnalysis_2023

Behavioral data analysis subfolder for Spatial Attention EEG
## Directory Structure
    ./
    ├── behavioraldata/ # includes res*.mat files for behavioral data
    ├── subjlist/       # subject list
    ├── figure/         # figure output folder   
    ├── figure_ANOVA/   # boxplots based on ANOVA anlaysis
    ├── ANOVA_analysis/ # ANOVA analysis datasheets (anova-kun style long format) and teh result sheet (anova-kun)
    ├── datasheet/      # datasheet CSVs of analized behavioral data
    ├── backnumbers/    # old scripts
    ├── reference/      # files referred by the main scrips 
    ├── +acc/           # functions calculate accuracies
    ├── answer.csv      # answer reference file for accuracy calculation
    ├── dataAnalysis_SA_SNR_accuracy_v*.mat	# main scripts for behavioral data analysis 
    ├── BehavData_YYYYMMDD.mat              # data file including accuracy scores and conditions (SNR, Spatial pattern), replaced by datasheet
    └── README.md                           # this document
    

## How to use
run 'dataAnalysis_SA_SNR_accuracy_v*.m', then figures and 'behav_alldata_*.csv' will be automatically generated. 

## Information
- Subject naming rule
    - *_b - means 'behavioral-only' experiment <br>
    SNR: 21,-18,-15,-12,-9 dB <br>
    Spatial Pattern: Colocated, Separate (masker:front), Separate (masker: back)
    - *_e - means 'EEG' experiment <br>
    SNR: -18,-12 dB <br>
    Spatial Pattern: Separate (masker: front), Separate (masker: back)
- Data selection <br>
    Figures show both all of the conditions (5*3) and EEG-version condition (2*2)
- Participants selection <br>
    For the participants who have been participated in the experiments multiple times, the earliest data has been selected.  

## History (YYYYMMDD)
- 20230330 <br>
    created
- 20260123 <br>
    latest analysis code is 'dataAnalysis_SA_SNR_accuracy_v7.m' <br>
    code and comments organization
