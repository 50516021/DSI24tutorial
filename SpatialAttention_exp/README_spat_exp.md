# SpatialAttention_exp – experiment scripts

Spatial attention (CRM) experiment scripts for EEG measurement.

CRM: coordinate response measure  
EEG: electroencephalography

This folder contains:

## Main scripts
- `SpAt_main_v2.m`  
	Main experiment script (EEG + OSC), using MATLAB Audio Toolbox `audiostreamer` (no Psychtoolbox required).
- `SpAt_prac_v2.m`  
	Practice version of the CRM test, also using `audiostreamer`.

## Utility / test scripts
- `test/SoundTest_v2.m`  
	Multichannel sound test using `audiostreamer` (sine tone + pink noise for each loudspeaker).
- `+data_load/makestimuluslist.m`  
	Stimulus list maker for the main/practice experiments.
- `+data_load/makstimulus.m`  
	Stimulus waveform generator used by the experiment scripts.
- `+utils/oscread.m`, `+utils/oscwrite.m`  
	OSC communication helpers for TouchOSC / iPad control.
- `+utils/fadein.m`, `+utils/fadeout.m`  
	Fade in/out functions for stimulus playback.

## Requirements

MATLAB and toolboxes:
- MATLAB with **Audio Toolbox** (for `audiostreamer`)
- **DSP System Toolbox** (UDP / OSC helpers)
- DSI Streamer (for DSI‑24 recording; run separately)

Psychtoolbox is **not required** for SpAt_main_v2 / SpAt_prac_v2 / SoundTest_v2.

## Procedure

1. Confirm DSI‑24 and DSI Streamer are configured and recording.  
2. Start the experiment script (`SpAt_main_v2.m` for main, `SpAt_prac_v2.m` for practice) in MATLAB.  
3. Select the desired audio output device when prompted (via `audiostreamer.getPlayerNames`).  
4. Control trial start/answers from the TouchOSC interface on iPad.

## Background
These scripts are originally made by Rai Sato, a member of Dr. Sungyoung Kim's lab at RIT.  
Akira Takeuchi modified them for EEG measurement and updated audio playback to Audio Toolbox `audiostreamer`.

## EEG devices
- DSI-24 (Wearable Sensing)

## Author

**Akira Takeuchi**<br>
- [github/50516021](https://github.com/50516021)
- [Official Homepage](https://akiratakeuchi.com/)

## License

Copyright © 2025, [Akira Takeuchi](https://github.com/50516021).
Released under the [MIT License](LICENSE).

[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/Studio-Infinity/SQA_subtest/blob/main/LICENSE


