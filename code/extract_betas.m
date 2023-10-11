%% fmri99 Extract Beta Series ROIs
% S.Srokova - Oct 2023

clear; clc
% Run settings file
run(fullfile('Z:\ruggdata\UTD\EXPT2\FMR\fmri99\fmri99_scripts\fmri99_settings.m'));
dirs = settings.dirs;

% Find the directory with masks
dirs.roi_mask = fullfile(dirs.analyses, 'ROI_masks');
cd(dirs.roi_mask);

% Specify ROI names
rois = {'PPA', 'LOC'};

% Load binary matrix and label voxels as 1/0 true/false
% If group mask is needed:
% group_mask = logical(niftiread('group_mask.nii')) % Make sure group mask is in the path
% PPA_mask = logical(niftiread('PPA.nii')) & group_mask; 
% LOC_mask = logical(niftiread('LOC.nii')) & group_mask;

% If group mask is not needed:
PPA_mask = logical(niftiread('PPA.nii'));
LOC_mask = logical(niftiread('LOC.nii'));

% Loop through all subjects
for i = 1:length(subIDs)
    
    % Determine subject and pull information
    curSub = subIDs{i};
    dirs.sub = fullfile(dirs.data, curSub);
    info_file = fullfile(dirs.sub, strcat(curSub, '_info.mat'));
    matfile = fullfile(dirs.analyses, 'study_trialwise/matfiles', strcat(curSub, '_study_data.mat'));
    load(info_file);
    load(matfile);
    
    fprintf(['Extracting data from ', curSub, ' ...\n']);
    
    % Loop through subject's matfile (which contains the field study_data)
    for j = 1:length(study_data)
        
        % Load the beta file with all voxel values
        beta_map = niftiread(study_data(j).beta_file);
       
        % Loop through ROIS
        for k = 1:length(rois)
            curROI = rois{k}; % Specify ROI
            curMask = eval(strcat(curROI, '_mask')); % Select the variable for the current ROI (but be careful using eval())
            
            % Save data in matfile
            study_data(j).extracted_data.(curROI) = beta_map(curMask); % select betas from voxels indexed "1"
            study_data(j).mean_beta.(curROI) = mean(study_data(j).extracted_data.(curROI)); % average across voxels
        end
    end
    save(matfile, 'study_data');
end