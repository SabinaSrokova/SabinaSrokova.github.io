%% Create fmri99 trialwise mat files - study phase
% Creating the following variables for the encoding data:
% beta file, category, subcategory, run,
% vividness rating, trial index at test (for reinstatement psa), memory bin
% S. Srokova - June 2023

% Clear and Run settings file
clear; clc;
run(fullfile('Z:\ruggdata\UTD\EXPT2\FMR\fmri99\fmri99_scripts\fmri99_settings.m'));
dirs = settings.dirs;

for i = 1:length(subIDs)
    
    % Grab subject information
    curSub = subIDs{i};
    dirs.sub = fullfile(dirs.data, curSub);
    info_file = fullfile(dirs.sub, strcat(curSub, '_info.mat'));
    load(info_file);
    
    % Ask for counterbalance
    CB = input([curSub, ' - what is the CB of this participant? \n']);
    
    %% Load study data
    cd(info.dirs.sub_beh); 
    study_data = struct();
    sub = curSub(8:10); % For csv files
    
    % Load csv files from each scanner run
    for j = 1:length(settings.study_epi_phases)
        
        % Load spreadsheets
        curStudy = sprintf('fmri99_study_%s_%s.csv', sub, num2str(j));
        study_data.(settings.study_epi_phases{j}) = readtable(curStudy);
        
        % Clear if there is an extra empty column column (sometimes added by csv psychopy output)
        if ismember('Var12', study_data.(settings.study_epi_phases{j}).Properties.VariableNames)
            study_data.(settings.study_epi_phases{j}) = study_data.(settings.study_epi_phases{j})(:,1:11); % keep only first 11 cols
        end
    end
    
    % Concatenate study into a single spreadsheet
    study_data.all = vertcat(study_data.study_1, study_data.study_2, study_data.study_3, study_data.study_4);
    
    %% Process behavioral responses at study
    
    % Fix behavioral responses; Turn into mat and place NaNs
    for j = 1:height(study_data.all)
        resp = study_data.all.response{j};
        study_data.all.RT{j} = str2num(char(study_data.all.RT(j)));
        
        if strcmpi(resp,'[''1'']')
            study_data.all.resp(j) = 1;
        elseif strcmpi(resp,'[''2'']')
            study_data.all.resp(j) = 2;
        elseif strcmpi(resp,'[''3'']')
            study_data.all.resp(j) = 3;
        elseif strcmpi(resp,'None')
            study_data.all.resp(j) = NaN;
            study_data.all.RT{j} = 0;
        else % conditions not met
            study_data.all.resp(j) = NaN; % they pressed something weird or pressed more than one button
            study_data.all.RT{j} = 0; %remove rt from double responses
            fprintf('You should check trial for study: '); disp(j); % Perform a visual check
        end
        
       % % Remove responses that were way too fast (Commented out for now)
        if study_data.all.RT{j} < 0.5
            study_data.all.resp(j) = NaN;
            study_data.all.RT{j} = 0;
            fprintf('RT was too fast for this trial: '); disp(j); % Perform a visual check
        end
        
    end
    
    % Remove old response column and keep the preprocessed one
    study_data.all = removevars(study_data.all, 'response');
    
    %% Load test data, concatenate...
    test_data = struct();
    for j = 1:length(settings.test_epi_phases)
        curTest = sprintf('fmri99_test_%s_%s.csv', sub, num2str(j));
        test_data.(settings.test_epi_phases{j}) = readtable(curTest);
        
        % Clear if there is an extra column column, only 14 expected
        if ismember('Var15', test_data.(settings.test_epi_phases{j}).Properties.VariableNames)
            test_data.(settings.test_epi_phases{j}) = test_data.(settings.test_epi_phases{j})(:,1:14);
        end
    end
    
    % Concatenate test
    test_data.all = vertcat(test_data.test_1, test_data.test_2, test_data.test_3, test_data.test_4);
        
    %% Define their key responses according to the counterbalance
    if  CB == 1
        old = 1; new = 2; scene = 1; object = 2; dk = 3;
    elseif CB == 2
        old = 2; new = 1; scene = 1; object = 2; dk = 3;
    elseif CB == 3
        old = 1; new = 2; scene = 2; object = 1; dk = 3;
    elseif CB == 4
        old = 2; new = 1; scene = 2; object = 1; dk = 3;
    elseif CB == 5
        old = 1; new = 2; scene = 2; object = 3; dk = 1;
    elseif CB == 6
        old = 2; new = 1; scene = 2; object = 3; dk = 1;
    elseif CB == 7
        old = 1; new = 2; scene = 3; object = 2; dk = 1;
    elseif CB == 8
        old = 2; new = 1; scene = 3; object = 2; dk = 1;
    end
    
    %% Fix behavioral responses; Turn into mat and place NaNs
    for j = 1:height(test_data.all)
        item_resp = test_data.all.response{j};
        source_resp = test_data.all.SourceResp{j};
        
        test_data.all.RT{j} = str2num(char(test_data.all.RT(j)));
        test_data.all.SourceRT{j} = str2num(char(test_data.all.SourceRT(j)));
        
        % Item memory
        if strcmpi(item_resp,'[''1'']')
            test_data.all.item_resp(j) = 1;
        elseif strcmpi(item_resp,'[''2'']')
            test_data.all.item_resp(j) = 2;
        elseif strcmpi(item_resp,'None')
            test_data.all.item_resp(j) = NaN;
            test_data.all.RT{j} = 0;
        else % conditions not met
            test_data.all.item_resp(j) = NaN; % they pressed something weird or pressed more than one button
            test_data.all.RT{j} = 0; %remove rt from double responses
            fprintf('You should check item response for retrieval trial: '); disp(j);
        end
        
        % Source memory
        if strcmpi(source_resp,'[''1'']')
            test_data.all.source_resp(j) = 1;
        elseif strcmpi(source_resp,'[''2'']')
            test_data.all.source_resp(j) = 2;
        elseif strcmpi(source_resp,'[''3'']')
            test_data.all.source_resp(j) = 3;
        elseif strcmpi(source_resp,'None')
            test_data.all.source_resp(j) = NaN;
            test_data.all.SourceRT{j} = 0;
        else % conditions not met
            test_data.all.source_resp(j) = NaN; % they pressed something weird or pressed more than one button
            test_data.all.SourceRT{j} = 0; %remove rt from double responses
            fprintf('You should check source response for retrieval trial: '); disp(j);
        end
    end
    
    % Remove old one, keep the preprocessed
    test_data.all = removevars(test_data.all, 'response');
    test_data.all = removevars(test_data.all, 'SourceResp');
    
    %% Start creating the mat file
    % Prepare variables
    beh_data = table2struct(study_data.all); % Study
    test_data = table2struct(test_data.all); % Test
    study_data = struct(); % We will be redoing this variable
    
    % Create values for each trial
    for j = 1:length(beh_data)
        
        % Create a beta file variable
        study_data(j).beta_file = fullfile(info.dirs.sub_studyTrialwise, sprintf('beta_%4.4d.nii',j));
        
        % category
        if beh_data(j).cat == 0
            study_data(j).category = 'filler';
        elseif beh_data(j).cat == 1
            study_data(j).category = 'scene';
        elseif beh_data(j).cat == 2
            study_data(j).category = 'object';
        else
            error('Did not assign category to trial');
        end
        
        % subcategory
        if beh_data(j).subcat == 0
            study_data(j).subcat = 'filler';
        elseif beh_data(j).subcat == 1
            study_data(j).subcat = 'indoor';
        elseif beh_data(j).subcat == 2
            study_data(j).subcat = 'outdoor';
        elseif beh_data(j).subcat == 3
            study_data(j).subcat = 'natural';
        elseif beh_data(j).subcat == 4
            study_data(j).subcat = 'manmade';
        else
            error('Did not assign subcategory to trial');
        end
        
        % run
        study_data(j).run = beh_data(j).run;
        
        % vividness rating
        if beh_data(j).resp == 1
            study_data(j).vivid_resp = 'not_vivid';
        elseif beh_data(j).resp == 2
            study_data(j).vivid_resp = 'somewhat';
        elseif beh_data(j).resp == 3
            study_data(j).vivid_resp = 'very_vivid';
        elseif isnan(beh_data(j).resp)
            study_data(j).vivid_resp = 'no_resp';
        else
            error('Did not assign vividness response to trial');
        end
        
        % Add test phase information
        if strcmpi(study_data(j).category, 'filler')
            study_data(j).test_idx = 0;
            study_data(j).mem_bin = 'none';
        else
            
            % Trial index, find the word at test
            cur_word = beh_data(j).word;
            study_data(j).test_idx = find(cellfun(@(x) strcmpi(x, cur_word), {test_data.word}));
        
            % Determine memory bin
            test_trial = test_data(study_data(j).test_idx);
            
                % Source correct
            if (test_trial.cat == 1 & test_trial.source_resp == scene) | ...
                    (test_trial.cat == 2 & test_trial.source_resp == object)
                study_data(j).mem_bin = 'source_correct';
                
                % Source incorrect
            elseif (test_trial.cat == 1 & test_trial.source_resp == object) | ...
                    (test_trial.cat == 2 & test_trial.source_resp == scene)
                study_data(j).mem_bin = 'source_incorrect';
                
                % Source DK
            elseif test_trial.source_resp == dk
                study_data(j).mem_bin = 'source_dk';
                
                % Source No Response (but recognized as old)
            elseif test_trial.item_resp == old & isnan(test_trial.source_resp)
                study_data(j).mem_bin = 'source_nr';
                
                % Item miss
            elseif test_trial.item_resp == new
                study_data(j).mem_bin = 'item_miss';
                
                % Item NR
            elseif isnan(test_trial.item_resp)
                study_data(j).mem_bin = 'item_nr';
                
            else
                error('Memory bin not assigned to trial');
            end
        end
    end
    
    % Check memory and vividness output 
    disp({'Not' 'Somewhat' 'Very' 'None'});
    disp({sum(strcmpi({study_data.vivid_resp}, 'not_vivid'))...
        sum(strcmpi({study_data.vivid_resp}, 'somewhat')) ...
        sum(strcmpi({study_data.vivid_resp}, 'very_vivid'))...
        sum(strcmpi({study_data.vivid_resp}, 'no_resp'))});
    
    disp({'SC' 'SI' 'SDK' 'SNR' 'Miss' 'NR'});
    disp({sum(strcmpi({study_data.mem_bin}, 'source_correct'))...
        sum(strcmpi({study_data.mem_bin}, 'source_incorrect')) ...
        sum(strcmpi({study_data.mem_bin}, 'source_dk'))...
        sum(strcmpi({study_data.mem_bin}, 'source_nr')) ...
        sum(strcmpi({study_data.mem_bin}, 'item_miss'))...
        sum(strcmpi({study_data.mem_bin}, 'item_nr'))});
    input('Press any button to continue if trial numbers look OK \n\n');
    
    % Save matfile
    matfile = fullfile(dirs.analyses, 'study_trialwise\matfiles', strcat(curSub, '_study_data.mat'));
    save(matfile, 'study_data');
    
    % Also save behavioral data in case I want it later...
    study_data = beh_data;
    beh_file = fullfile(dirs.sub, strcat(curSub, '_behavioral_data.mat'));
    
    save(beh_file, 'study_data', 'test_data', 'CB');
    
    clearvars -except dirs subIDs settings
end
