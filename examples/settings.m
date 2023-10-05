%% fMRI99 Settings

%% Directories
settings.dirs.root = fullfile('Z:','ruggdata','UTD','EXPT2','FMR','fmri99');
settings.dirs.data = fullfile(settings.dirs.root, 'fmri99_data');
settings.dirs.analyses = fullfile(settings.dirs.root, 'fmri99_analyses');
settings.dirs.motion = fullfile(settings.dirs.root, 'fmri99_motion');
settings.dirs.onsets = fullfile(settings.dirs.root, 'fmri99_onsets');
settings.dirs.scripts = fullfile(settings.dirs.root, 'fmri99_scripts');
settings.dirs.templates = fullfile(settings.dirs.root, 'fmri99_templates');
settings.dirs.misc = fullfile(settings.dirs.scripts, 'functions');

addpath(fullfile(settings.dirs.scripts, 'functions'));

%% Templates
settings.template.mni_epi = fullfile(settings.dirs.templates, 'SPM_EPI.nii');
settings.template.mni_t1 = fullfile(settings.dirs.templates, 'SPM_T1.nii');
settings.template.fmri97_epi = fullfile(settings.dirs.templates, 'fmri99_epi_template_all.nii');
settings.template.fmri97_t1 = fullfile(settings.dirs.templates, 'fmri99_t1_template_all.nii');


%% Preprocess and GLM (no slice time correction)
settings.TR = 1.52;                 % TR
settings.nSlices = 66;              % Slices per volume
settings.mbFactor = 3;              % MB
settings.study_vols = 184;          % Volumes per run
settings.test_vols = 349;

settings.mask_thresh = 0.5;         % Masking threshold
settings.smooth.kernel = [5 5 5];   % Smoothing kernel 

settings.fd.headRadius = 50; % Use a radius of 50 mm to convert rotation realignment parameters to mm

% Spike Detection
settings.spikes.fdThresh = 2;       % Maximum amount of scan-to-scan movement before it is counted as a spike for FD
settings.spikes.tThresh = 1;        % Maximum amount of scan-to-scan translation before it is a spike for RP
settings.spikes.rThresh = 1;        % Maximum amount of rotation (in degrees) before it is a spike for RP
settings.spikes.spikeWin = [1 1];   % Number of scans before and after a spike to include in spike regressor

% Fieldmap
settings.tert = 37.95;              % Total EPI readout time (ms) 
% as 1/BandwidthPerPixelPhaseEncode or as Echo Spacing/Accel. factor PE * EPI factor

settings.e1 = 4.92;                 % Echo Time for echo 1
settings.e2 = 7.38;                 % Echo Time for echo 2

% Dimensions for checking nii conversion
settings.mprage.dims = [160 256 256];
settings.hires.dims = [512 512 40];
settings.epi.study_dims = [110 110 66 184];
settings.epi.test_dims = [110 110 66 349];

settings.study_epi_phases = {'study_1' 'study_2' 'study_3' 'study_4'};
settings.test_epi_phases = {'test_1' 'test_2' 'test_3' 'test_4'};
settings.epi_phases = [settings.study_epi_phases, settings.test_epi_phases];

%% Eyetracking
% pix 1,1 = 0,0. Middle of the screen is 959,539
settings.etk.img_coord_x = [509, 1409];
settings.etk.img_coord_y = [89, 989];

% https://www.sr-research.com/visual-angle-calculator/ 
% 405 mm width; 257 height; 1030mm distance
settings.spikes.gazeThresh_x = 85.23;     % 1 degree visual angle horizontal
settings.spikes.gazeThresh_y = 75.55;     % 1 degree visual angle vertical

%% Subject selection

allSubs = dir(fullfile(settings.dirs.data));
allSubs = {allSubs.name};
[SELECTION,OK] = listdlg( ...
    'PromptString','Select subject(s) to analyze:', ...
    'SelectionMode','multiple','ListString',allSubs, ...
    'ListSize',[200 500]);

% Create subID list and kill script if none selected
subIDs = allSubs(SELECTION);
if isempty(subIDs); error('No subjects were selected for analysis!'); end

clearvars -except settings subIDs
