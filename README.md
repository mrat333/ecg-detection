# ECG Detection in MATLAB

R-peak (QRS) detection, heart-rate / HRV analysis and simple rhythm screening for single-lead ECG signals, using a Pan-Tompkins style pipeline.

## Features
- Load ECG from `.csv`, `.mat`, or generate a synthetic ECG for testing
- Band-pass filtering + 50/60 Hz notch + baseline wander removal
- Pan-Tompkins QRS detector with adaptive thresholding
- Heart rate, RR intervals, HRV metrics (SDNN, RMSSD, pNN50)
- Rule-based rhythm screening (normal / bradycardia / tachycardia / irregular)
- Plots of raw vs filtered signal, detected R-peaks, and heart-rate trend

## Requirements
- MATLAB R2018b or newer
- Signal Processing Toolbox (`butter`, `filtfilt`, `findpeaks`, `iirnotch`)

## Project structure
```
ecg-detection-matlab/
├── main_ecg_detection.m        % run this
├── src/
│   ├── load_ecg.m
│   ├── generate_synthetic_ecg.m
│   ├── preprocess_ecg.m
│   ├── detect_qrs_pan_tompkins.m
│   ├── compute_hrv.m
│   └── classify_rhythm.m
├── data/                       % put your ECG files here
├── results/                    % saved figures
├── LICENSE
└── README.md
```

## Quick start
```matlab
% 1. Open the project folder in MATLAB
% 2. Run:
main_ecg_detection
```
By default it runs on a synthetic ECG. To use your own data, edit the top of `main_ecg_detection.m`:
```matlab
cfg.source = 'file';
cfg.file   = 'data/my_ecg.csv';   % one column of samples, or .mat with variable "ecg"
cfg.fs     = 360;                 % sampling frequency in Hz
```

## Using real datasets
Download records from [PhysioNet MIT-BIH Arrhythmia Database](https://physionet.org/content/mitdb/1.0.0/), export a single lead to CSV (or `.mat` with variables `ecg` and optionally `fs`), and place it in `data/`.

## How the detector works
1. Band-pass 5–15 Hz to isolate QRS energy
2. Derivative to capture QRS slope
3. Squaring to make all values positive and emphasise large slopes
4. Moving-window integration (~150 ms)
5. Adaptive signal/noise thresholds to pick candidate peaks
6. Refinement of each peak to the true R-peak on the filtered ECG

## Disclaimer
This project is for education and research. It is **not** a medical device and must not be used for diagnosis.

## License
MIT
