# Spatial Attention: DSI-24 tutorial
Tutorial and utilities for Spatial Attention by using Wearable Sensing DSI-24

This repository contains example scripts and utilities for running a
spatial attention (Spatial Attention) experiment with the Wearable Sensing
DSI-24 EEG system, and for organizing and processing the recorded data.

The project is organized into two main parts:

- `SpatialAttention_exp/` – MATLAB scripts and resources for running the
  spatial attention experiment.
- `SpatialAttention_anl/` – example data folders and a workspace for
  analysis scripts on DSI-24 recordings.

### Experiment requirements

To run the experiment scripts in `SpatialAttention_exp/` (e.g. `SpAt_main_v2.m`, `SpAt_prac_v2.m`, `test/SoundTest_v2.m`), you will need:

- MATLAB with **Audio Toolbox** (for the `audiostreamer` audio output)  
- **DSP System Toolbox** (UDP / OSC communication utilities)  
- A DSI-24 system with DSI Streamer (for EEG recording; started separately)

Note: the current versions of the main and practice scripts no longer require Psychtoolbox for audio playback.  
Earlier versions of the experiment scripts (e.g. `SpAt_main.m`, `SpAt_prac.m`, older test scripts) are still available in this repository and use Psychtoolbox-based audio.

---

## Directory Structure

```text
DSI24tutorial/
├── [README.md](http://_vscodecontentref_/4)
├── SpatialAttention_exp/      # Experiment (stimulus presentation, triggers, OSC, tests)
└── SpatialAttention_anl/      # Example raw data and analysis workspace

```

## DSI-24 tutorial 
Here are some useful links officially provided by [Wearable Sensing](https://wearablesensing.com/):

Connecting to PC

- [This video](https://youtu.be/B-sn_LRXB7A) goes
over how to set up wireless and wired
connections to the system.

Donning/Doffing/Operation

- [This video](https://youtu.be/n59Uj_rQAjg) is a
donning tutorial of the DSI-24.

Signal Quality/Diagnostic Protocol

- [This video](https://youtu.be/6juYPfUCEbA) is a
detailed breakdown of the signal quality test, as well as what kind of artifacts can occur (such as CBA) and how to address them

DSI Streamer

- [This video](https://youtu.be/fwekDusaxV8) is a
detailed breakdown of how to use DSI Streamer, which will go over things including how to record, how to create custom montages, and more

Cleaning & Maintenance

- [This video](https://youtu.be/nTn2-z9ssmU) has
information on cleaning, how to replace electrodes, and how to properly pack and store the system

Human Subject Safety

- [This video](https://youtu.be/rlxmvyxiVyU) has
information on headaches, lice, skin issues, and hair products that can't be used with the system


## Author

**Akira Takeuchi**<br>
- [github/50516021](https://github.com/50516021)
- [Official Homepage](https://akiratakeuchi.com/)

## License

Copyright © 2025, [Akira Takeuchi](https://github.com/50516021).
Released under the [MIT License](LICENSE).

[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/Studio-Infinity/SQA_subtest/blob/main/LICENSE