# SpatialAttention_anl
Workspace for Spatial Attention analysis with Wearable Sensing DSI-24

This folder provides a small workspace and example data for analyzing
EEG recordings from the Spatial Attention (SpAt) experiment conducted
with the Wearable Sensing DSI-24 system.

- Example raw EEG/behavioral data: `01_OriginalData/`
- Main experiment / stimulus scripts: see `../SpatialAttention_exp/`
- EEG analysis scripts (step-wise pipeline): see `../02_EEG_analysis/`

---

## EEG analysis pipeline (overview)

The core analysis for the Spatial Attention experiment is implemented
as a series of MATLAB scripts in `../02_EEG_analysis/`:

1. `SPAt_analysis1_epoching.m`
	 - Loads Biosemi (BDF) or DSI-24 (CSV/EDF via EEGLAB) EEG recordings
		 together with the subject's behavioral metadata (`res_*.mat`).
	 - Detects masker and target onset triggers and, if necessary,
		 re-aligns trials when the experiment was restarted mid-session.
	 - Applies band-pass filtering (e.g., 1.5–20 Hz), defines a baseline
		 interval, and creates epoched EEG data around masker and target
		 onsets.
	 - Resamples epochs to 256 Hz and saves:
		 - `step1_Msk_*.mat` – masker-locked epochs
		 - `step1_Tgt_*.mat` – target-locked epochs

2. `SPAt_analysis2_artrmv1.m`
	 - First artifact handling / cleaning step on the epoched data.
	 - Typical operations include inspecting channels/trials and applying
		 basic artifact rejection. See comments in the script for details.

3. `SPAt_analysis3_artrmv2.m`
	 - Second-stage artifact processing on the cleaned data from step 2.
	 - May include additional rejection or correction procedures to
		 obtain a final set of clean epochs.

4. `SPAt_analysis4_evoked_response_v2.m`
	 - Computes evoked responses (e.g., condition-wise averaged signals)
		 based on the artifact-cleaned epochs from previous steps.
	 - Produces summary variables and figures for further statistical
		 analysis and visualization.

For the exact procedures (channel selection, artifact criteria,
conditions, etc.), please refer to the comments inside each
`SPAt_analysis*.m` script in `../02_EEG_analysis/`.

---

## How to use this folder

1. Place new subject data under `01_OriginalData/` following the same
	 structure as the provided example.
2. Open MATLAB and make `DSI24tutorial/` your working directory.
3. Run the EEG analysis scripts in `02_EEG_analysis/` in order
	 (`SPAt_analysis1_epoching.m` → `SPAt_analysis2_artrmv1.m` →
	 `SPAt_analysis3_artrmv2.m` → `SPAt_analysis4_evoked_response_v2.m`).
4. Inspect the generated `.mat` files and figures within the
	 `subject/` folders for each participant.

See `../README.md` for an overview of the whole DSI-24 tutorial
project and additional links to official Wearable Sensing resources.
