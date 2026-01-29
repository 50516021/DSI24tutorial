# BDFanalysis_EEG

EEG (BDF) data analysis subfolder for Spatial Attention EEG
## Directory Structure
    ./
    ├── SPAt_analysis1_epoching.m        # step1: epoching & .mat generation
    ├── SPAt_analysis2_artrmv1.m            # step2: artifact removal (coarse threshold)
    ├── SPAt_analysis3_artrmv2.m            # step3: additional artifact processing
    ├── SPAt_analysis4_evoked_responce.m # evoked response calculation
    ├── Evl_RMS_*.m                         # RMS analysis scripts
    ├── Evl_peak_*.m                        # peak analysis scripts
    ├── Evl_GFP.m                           # GFP analysis script
    ├── peakanalysis/                       # peak-related helper scripts
    ├── openbdf.m, readbdf.m                # BDF reading functions
    ├── LocationFiles/                      # electrode location files
    ├── subject/, subjectlist/              # subject data & subject lists
    ├── EEGgearcomp/                        # EEG device comparison scripts
    ├── figure/                             # figure output folder
    ├── +cal/, +plots/, +utils/             # analysis, plotting, utility functions
    ├── answer.csv                          # condition info & answer reference
    ├── LICENSE                             # license
    └── README_BDF.md                       # this document
    
## required Toolboxes
- EEGlab

## How to use

### step1
Run 'SPAt_analysis1_epoching_v*.m'
- Epoching and making a mat file with EEG and triggers
- Outputs: step1_*.mat

### step2
Run 'SPAt_analysis2_artrmv1.m'
- Extraction of noisy trials and channels
- Outputs:
  - step2_*_thTr.pdf
  - step2_*_thCh.pdf
  - step2_*_extraction.mat
  - step2_*_RejectionThresholds_trials_channels.mat

### step3
Run 'SPAt_analysis3_artrmv2.m'
- Additional artifact removal processing
- Outputs: step3_*.mat

### step4
Run 'SPAt_analysis4_evoked_responce_v*.m'
- re-reference
- Calculate evoked responses
- Outputs: step4_*.mat

### step5 (Analysis)
Run 'Evl_RMS_*.m', 'Evl_peak_*.m', 'Evl_GFP.m', etc.
- Generate figures and summary files
- Outputs: figures in figure/ and data summary files 

## Information
- Participants selection <br>
    For the participants who have been participated in the experiments multiple times, the earliest data has been selected.  
- EEG devices <br>
    BioSemi ActiveTwo (16ch), DSI-24 (use *_DSI24ver.m scripts)

## History (YYYYMMDD)
- 20230102 <br>
	made for SNR behavioral data
- 20260123 <br>
    README format aligned with BehavioralAnalysis_2023; updated directory structure and usage description
