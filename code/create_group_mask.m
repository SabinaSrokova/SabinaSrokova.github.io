%% fmri93: Create a group mask for unsmoothed data
% S.Srokova - October 2020 [note this code is old and can be made more efficient]

%% Set path and variables

mainDir = 'S:\UTD\EXPT2\FMR\fmri93\';
analysisDir = strcat(mainDir,'fmri93_analyses\');
dataDir = strcat(mainDir,'fmri93_data\');
betaDir = strcat(analysisDir, 'Test_phase_SingleTrial\individual\'); % where the betas hide

subs = {'y03' 'y05' 'y06' 'y07' 'y08' 'y10' 'y11' 'y12' 'y13' 'y14' 'y15' 'y17' 'y18' ...
    'y19' 'y20' 'y21' 'y22' 'y23' 'y25' 'y26' 'o01' 'o02' 'o04' 'o05' 'o06' 'o07' 'o09' 'o11' ...
    'o13' 'o15' 'o16' 'o17' 'o18' 'o19' 'o20' 'o21' 'o22' 'o23' 'o24' 'o25' 'o26' 'o28' 'o29' 'o30'};

%%Create conjoint mask with all subs
for n = 1:length(subs)
    sub = subs{n};
    sub = strcat('fmri93_', sub);
    temp = spm_read_vols(spm_vol(fullfile(betaDir,sub,'mask.nii')));
    if n == 1
        conjMask = temp;
    else
        conjMask = conjMask & temp;
    end
end
HDR = spm_vol(fullfile(betaDir,sub,'mask.nii'));
HDR.fname = fullfile(betaDir,'group_mask.nii');
spm_write_vol(HDR,conjMask);
conjMask = conjMask > 0;