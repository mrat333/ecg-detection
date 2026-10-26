%% ECG DETECTION - MAIN SCRIPT
% Loads an ECG, filters it, detects R-peaks, computes HR/HRV and screens rhythm.
clear; clc; close all;
addpath('src');

%% ---------------- CONFIGURATION ----------------
cfg.source   = 'synthetic';      % 'synthetic' or 'file'
cfg.file     = 'data/my_ecg.csv';% used when source = 'file'
cfg.fs       = 360;              % sampling frequency (Hz)
cfg.duration = 30;               % seconds (synthetic only)
cfg.mains    = 50;               % mains frequency: 50 (India/EU) or 60 (US)
cfg.saveFig  = true;

%% ---------------- LOAD ----------------
[ecg, fs] = load_ecg(cfg);
t = (0:numel(ecg)-1) / fs;

%% ---------------- PREPROCESS ----------------
ecg_f = preprocess_ecg(ecg, fs, cfg.mains);

%% ---------------- DETECT QRS ----------------
[rIdx, ~] = detect_qrs_pan_tompkins(ecg_f, fs);

%% ---------------- HRV + RHYTHM ----------------
hrv    = compute_hrv(rIdx, fs);
rhythm = classify_rhythm(hrv);

fprintf('\n===== ECG ANALYSIS RESULTS =====\n');
fprintf('Duration        : %.1f s (fs = %d Hz)\n', t(end), fs);
fprintf('Beats detected  : %d\n', numel(rIdx));
fprintf('Mean heart rate : %.1f bpm\n', hrv.meanHR);
fprintf('Mean RR         : %.1f ms\n', hrv.meanRR);
fprintf('SDNN            : %.1f ms\n', hrv.sdnn);
fprintf('RMSSD           : %.1f ms\n', hrv.rmssd);
fprintf('pNN50           : %.1f %%\n', hrv.pnn50);
fprintf('Rhythm screen   : %s\n', rhythm);
fprintf('(Educational use only - not a medical diagnosis)\n\n');

%% ---------------- PLOTS ----------------
fig = figure('Name','ECG Detection','Position',[100 100 1000 750]);

subplot(3,1,1);
plot(t, ecg, 'Color',[0.5 0.5 0.5]); grid on;
title('Raw ECG'); xlabel('Time (s)'); ylabel('Amplitude');

subplot(3,1,2);
plot(t, ecg_f, 'b'); hold on;
plot(t(rIdx), ecg_f(rIdx), 'ro', 'MarkerFaceColor','r');
grid on; legend('Filtered ECG','Detected R-peaks');
title(sprintf('Filtered ECG with R-peaks (%d beats)', numel(rIdx)));
xlabel('Time (s)'); ylabel('Amplitude');

subplot(3,1,3);
if numel(rIdx) > 1
    rr = diff(rIdx)/fs;
    plot(t(rIdx(2:end)), 60./rr, '-o', 'LineWidth',1.2); grid on;
end
title('Instantaneous Heart Rate'); xlabel('Time (s)'); ylabel('bpm');

if cfg.saveFig
    if ~exist('results','dir'), mkdir('results'); end
    saveas(fig, fullfile('results','ecg_detection.png'));
end
