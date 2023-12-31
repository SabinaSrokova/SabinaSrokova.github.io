%% fMRI99 Beta Series - Study
% S. Srokova - 05/28/2023

clear; clc;
% Run settings file and load SPM
run(fullfile('Z:\ruggdata\UTD\EXPT2\FMR\fmri99\fmri99_scripts\fmri99_settings.m'));
dirs = settings.dirs;
spm fmri

% Loop through subjects
for i = 1:length(subIDs)
    %% Determine subject and pull info
    curSub = subIDs{i};
    dirs.sub = fullfile(dirs.data, curSub);
    info_file = fullfile(dirs.sub, strcat(curSub, '_info.mat')); 
    load(info_file); 

    % Make GLM directory for current subject
    info.dirs.sub_studyTrialwise = fullfile(dirs.analyses, 'study_trialwise\LSA_individual', curSub);
    if ~exist(info.dirs.sub_studyTrialwise, 'dir'); mkdir(info.dirs.sub_studyTrialwise); end
    
    % Get onsets, store them in the info file
    onsetFile = strcat(curSub,'_study_trialwise_onsets.mat');
    info.files.onsets.studyTrialwise = fullfile(dirs.onsets, 'trialwise', onsetFile);    
    load(info.files.onsets.studyTrialwise);
    info.onsets.studyTrialwise = struct('names', {names}, 'durations', {durations}, 'onsets', {onsets});
    
    % Make motion file without spikes
    mocoRegs = vertcat(info.motion.study_1.rpRegs, info.motion.study_2.rpRegs, info.motion.study_3.rpRegs, info.motion.study_4.rpRegs);
    info.motion.studyTrialwise = mocoRegs; % Save concatenated realignment paramenters in the info file
    info.files.motion.studyTrialwise = fullfile(dirs.motion, curSub, strcat(curSub, '_study_betaseries_regressors.txt'));
    
    % Write a new regressor file with concatenated rps
    dlmwrite(info.files.motion.studyTrialwise, info.motion.studyTrialwise);
    
    % Get functional images; smoothed
    studyIMGs = vertcat(info.files.expanded.smooth.study_1, info.files.expanded.smooth.study_2, ...
         info.files.expanded.smooth.study_3, info.files.expanded.smooth.study_4);

    
    %% Specify and Estimate 1st level
    cd(info.dirs.sub_studyTrialwise);
    spm_mat = fullfile(info.dirs.sub_studyTrialwise,'SPM.mat');

    % Specify settings
    job{1}.spm.stats.fmri_spec.dir = cellstr(info.dirs.sub_studyTrialwise); 
    job{1}.spm.stats.fmri_spec.timing.units = 'secs'; 
    job{1}.spm.stats.fmri_spec.timing.RT = settings.TR; 
    job{1}.spm.stats.fmri_spec.timing.fmri_t = 16; 
    job{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    job{1}.spm.stats.fmri_spec.sess.scans = cellstr(studyIMGs); 
    job{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    job{1}.spm.stats.fmri_spec.sess.multi = cellstr(info.files.onsets.studyTrialwise); % Onsets
    job{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    job{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(info.files.motion.studyTrialwise); % Motion regressors
    job{1}.spm.stats.fmri_spec.sess.hpf = 128;
    job{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    job{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; % No derivatives!
    job{1}.spm.stats.fmri_spec.volt = 1;
    job{1}.spm.stats.fmri_spec.global = 'None';
    job{1}.spm.stats.fmri_spec.mthresh = settings.mask_thresh; % 0.5
    job{1}.spm.stats.fmri_spec.mask = {''};
    job{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    % Run specification
    spm_jobman('run',job);
    clear job;
    
    % Concatenate sessions with spm_fmri_concatenate
    nScans = repmat(settings.study_vols,1,length(settings.study_epi_phases));
    spm_fmri_concatenate(spm_mat,nScans);
    
    % Estimate model
    job{1}.spm.stats.fmri_est.spmmat = cellstr(spm_mat);
    job{1}.spm.stats.fmri_est.write_residuals = 0;
    job{1}.spm.stats.fmri_est.method.Classical = 1;
    spm_jobman('run',job);
    clear job;
    
    % Save info file
    save(info_file, 'info');
    
end
