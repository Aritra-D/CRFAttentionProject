function [full_data] = getData_SRCLongProtocols(protocolType,gridType)
    capType = 'actiCap64';  
    get_data_for_all_subjects(protocolType, gridType, capType);
end

% Accessory Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Accessory Functions  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load LFP Info
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
    load(fullfile(folderLFP,'lfpInfo.mat'));
    analogChannelsStored=sort(analogChannelsStored); %#ok<NODEF>
    if ~exist('analogInputNums','var')
        analogInputNums=[];
    end
end

% Get parameter combinations
function [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,...
    aValsUnique,sValsUnique] = ...
    loadParameterCombinations(folderExtract)
    load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>
end

% Get Bad Trials
function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
    load(badTrialFile);
end

% Get Induced LFP data by subtracting trialaveraged ERP data from trialwise LFP Data
% function Y = removeERP(X)
% Y = X-repmat(mean(X,1),size(X,1),1);
% end

% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)
    posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
    eValue   = sum(mEnergy(posToAverage,:),1);
end

function get_data_for_all_subjects(protocolType, gridType, cap_type)    
    [subjects, expDates, protocolNames, dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType, protocolType);
    grid_type = 'EEG';
    computed = cell(length(subjects),4);
    for subject_idx = 1: length(subjects)
        tic
        subject = num2str(subjects{subject_idx});
        exp_date = num2str(expDates{subject_idx});
        protocol = num2str(protocolNames{subject_idx});
        disp(['SUBJECT: ' subject ', EXPDATE:' exp_date, ', PROTOCOL:' protocol])
        
        if subject_idx < 8 % First Set of Recording- Nov-Dec 2021
            freqRanges{1} = [8 12];    % alpha
            freqRanges{2} = [26 56];   % gamma
            freqRanges{3} = [23 23];   % SSVEP Left Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
            freqRanges{4} = [31 31];   % SSVEP Right Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
            freqRanges{5} = [26 34];   % Slow Gamma
            freqRanges{6} = [44 56];   % Fast Gamma
            freqRanges{7} = [102 250]; % High Gamma
            
        else % Second Set of Recording- Jan-Mar 2022
            
            freqRanges{1} = [8 12];    % alpha
            freqRanges{2} = [26 56];   % gamma
            freqRanges{3} = [24 24];   % SSVEP Left Stim; Flicker Freq bug Fixed
            freqRanges{4} = [32 32];   % SSVEP Right Stim; Flicker Freq bug Fixed
            freqRanges{5} = [26 34];   % Slow Gamma
            freqRanges{6} = [44 56];   % Fast Gamma
            freqRanges{7} = [102 250]; % High Gamma
        end
        
        clear badTrials badElectrodes
        folderName = fullfile(dataFolderSourceString, 'data', subject, grid_type, exp_date, protocol);
        folderExtract = fullfile(folderName, 'extractedData');
        folderSegment = fullfile(folderName, 'segmentedData');
        folderLFP = fullfile(folderSegment, 'LFP');

        % Set up movingWindow parameters for time-frequency plot
        winSize = 0.1;
        winStep = 0.025;
        movingwin = [winSize winStep];

        % Electrode and trial related Information
        photoDiodeChannels = [65 66];
        
        % Get Parameter Combinations for SRC-Long Protocols
        [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,aValsUnique,sValsUnique]= ...
            loadParameterCombinations(folderExtract); %#ok<ASGLU>

        %trials
        trials = parameterCombinations.stimOnset;

        % Get bad trials
        badTrialFile = fullfile(folderSegment, 'badTrials_v5.mat');
        if ~exist(badTrialFile, 'file')
            disp('Bad trial file does not exist...');
            bad_trials = [];
        else
            [bad_trials, ~] = loadBadTrials(badTrialFile);            
            % disp([num2str(length(bad_trials)) ' bad trials']);
        end
        
        unipolar_bad_electrodes = get_bad_electrodes(cap_type, 'unipolar', folderSegment);
        bipolar_bad_electrodes = get_bad_electrodes(cap_type, 'bipolar', folderSegment);
        unipolar_data = get_data_for_one_subject(cap_type, 'unipolar', eValsUnique, folderLFP, trials, bad_trials, freqRanges);
        bipolar_data = get_data_for_one_subject(cap_type, 'bipolar', eValsUnique, folderLFP, trials, bad_trials, freqRanges);

        computed{subject_idx, 1} = unipolar_bad_electrodes;
        computed{subject_idx, 2} = unipolar_data;
        computed{subject_idx, 3} = bipolar_bad_electrodes;
        computed{subject_idx, 4} = bipolar_data;
        
        tmp_computed = computed(subject_idx,:);
        folderSave = 'E:\';
        saveFileName = fullfile(folderSave, [protocolType '_' gridType '_Subject_' num2str(subject_idx) '.mat']);
        save(saveFileName,'tmp_computed')
        toc
    end    
end

function [badElecs, badHighPriorityElecs] = get_bad_electrodes(cap_type, ref_type, folderSegment)
    highPriorityElectrodeNums = getHighPriorityElectrodes(cap_type);

    badTrialFile = fullfile(folderSegment, 'badTrials_v5.mat');
    if ~exist(badTrialFile, 'file')
        disp('Bad trial file does not exist...');
        badElectrodes = [];
    else
        [~, badElectrodes] = loadBadTrials(badTrialFile);            
        % disp([num2str(length(badElectrodes)) ' bad electrodes']);
    end

    badElecsAll = unique([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs; badElectrodes.flatPSDElecs]); % TODO: correct last variable
    
    % load LFP Info
    folderLFP = fullfile(folderSegment,'LFP');
    [analogChannelsStored,~,~,~] = loadlfpInfo(folderLFP);

    if strcmp(ref_type, 'unipolar')
        badHighPriorityElecs = intersect(highPriorityElectrodeNums, badElecsAll);
        badElecs = intersect(analogChannelsStored, badElecsAll);
        % disp(['Unipolar, all bad elecs: ' num2str(length(badElecsAll)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityElectrodeNums,badElecsAll))) ]);            
    elseif strcmp(ref_type, 'bipolar')
        count =1; badBipolarElecs = [];
        electrodes = getElectrodeList(cap_type, ref_type, 1);
        for iBipolarElec = 1:length(electrodes)
            if any(electrodes{iBipolarElec}{1}(1) == badElecsAll) || any(electrodes{iBipolarElec}{1}(2) == badElecsAll)
                badBipolarElecs(count) = iBipolarElec;
                count = count+1;
            end
        end
        
        if ~exist('badBipolarElecs', 'var')
            badBipolarElecs = [];
        end
        
        badElecs = badBipolarElecs;
        highPriorityBipolarElectrodeNums = [93 94 101 102 96 97 111 107 112]; % TODO: will be moved later
        badHighPriorityElecs = intersect(highPriorityBipolarElectrodeNums, badBipolarElecs);
        % disp(['Bipolar, all bad elecs: ' num2str(length(badBipolarElecs)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityBipolarElectrodeNums, badBipolarElecs))) ]);
    end
end

function [computed] = get_data_for_one_subject(cap_type, ref_type, eValsUnique, folderLFP, trials, bad_trials, freqRanges)
    electrodes = getElectrodeList(cap_type, ref_type, 1);
    computed = cell(1,length(electrodes));

    % load LFP Info
    [~, timeVals, ~, ~] = loadlfpInfo(folderLFP);
    Fs = round(1/(timeVals(2)-timeVals(1)));

    for elec_idx = 1: length(electrodes)
        if strcmp(ref_type, 'unipolar')
            x = load(fullfile(folderLFP,['elec' num2str(electrodes{elec_idx}{1}) '.mat']));
        elseif strcmp(ref_type, 'bipolar')
            x1 = load(fullfile(folderLFP,['elec' num2str(electrodes{elec_idx}{1}(1)) '.mat']));
            x2 = load(fullfile(folderLFP,['elec' num2str(electrodes{elec_idx}{1}(2)) '.mat']));
            x.analogData.stimOnset = x1.analogData.stimOnset-x2.analogData.stimOnset;
            x.analogData.targetOnset = x1.analogData.targetOnset-x2.analogData.targetOnset;
        end
        computed{elec_idx} = get_good_trials_for_all_eot_codes(eValsUnique, x.analogData, timeVals, trials, bad_trials, freqRanges);
    end
end

function [computed] = get_good_trials_for_all_eot_codes(eot_codes, analog_data, timeVals, trials, bad_trials, freqRanges)
    computed = cell(1,length(eot_codes));
    attend_locs = [0 1];
    for eot_code_idx = 1: length(eot_codes)
        computed{eot_code_idx} = get_good_trials_for_all_attend_locs(attend_locs, analog_data, timeVals, trials(:,:,eot_code_idx,:), bad_trials, freqRanges);
    end
end

function [computed] = get_good_trials_for_all_attend_locs(attend_locs, analog_data, timeVals, trials, bad_trials, freqRanges)
    computed = cell(1,length(attend_locs));
    tf = [0 1 2];
    for attend_loc_idx = 1: length(attend_locs)
        computed{attend_loc_idx} = get_good_trials_for_all_tf(tf, analog_data, timeVals, trials(:,:, attend_loc_idx), bad_trials, freqRanges);
    end
end

function [computed] = get_good_trials_for_all_tf(tf, analog_data, timeVals, trials, bad_trials, freqRanges)
    computed = cell(length(tf),2);

    keySet = {'Baseline', 'Stimulus', 'Pre_Target'};
    valueSet = {[-1.000 0], [0.250 1.250], [-1.000 0]};
    t_map = containers.Map(keySet,valueSet);

    % Set up params for MT
    params.tapers   = [1 1];
    params.pad      = -1;
    params.Fs       = 1000;
    params.fpass    = [0 250];
    params.trialave = 0;

    for tf_idx = 1: length(tf)
        good_trial = get_good_trials(trials(:,tf_idx), bad_trials);
        computed{tf_idx, 1} = good_trial;
        computed{tf_idx, 2} = get_PSD_for_all_time_periods(t_map, analog_data, timeVals, good_trial, params, freqRanges);
    end
end

function [good_trials] = get_good_trials(trials_cell, bad_trials)
    trials = cell2mat(trials_cell);
    good_trials = setdiff(trials, bad_trials);
    % disp(good_trials);
end

function get_ERP(data,timeVals,good_trial,timePeriods)
    erpRange = timingParameters.erpRange;
    erpRangePos = round(diff(erpRange)*Fs);
    erpPos = find(timeVals>=timingParameters.erpRange(1),1)+ (1:erpRangePos);  
    
    % erp
    erp_stimOnset = mean(x.analogData.stimOnset(goodPos_stimOnset,:),1);
    erp_targetOnset = mean(x.analogData.targetOnset(goodPos_targetOnset,:),1);
    % Baseline Correction
    erp_stimOnset = erp_stimOnset - repmat(mean(erp_stimOnset(:,blPos),2),1,size(erp_stimOnset,2));
    erp_targetOnset = erp_targetOnset - repmat(mean(erp_targetOnset(:,blPos),2),1,size(erp_targetOnset,2));
    
    erpStim(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = erp_stimOnset;
    erpTarget(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = erp_targetOnset;
    RMSValsBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_stimOnset(blPos));
    RMSValsERP_Stim(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_stimOnset(erpPos));
    RMSValsERP_Target(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_targetOnset(erpPos));
end

function get_fft(data,timeVals,good_trial,params,time_periods,freqRanges)
    % fft
    fftBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,blPos),[],2))))); %#ok<*NASGU,*AGROW>
    fftST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,stPos),[],2)))));
    fftTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.targetOnset(goodPos_targetOnset,tgPos),[],2)))));
    freqVals_fft = 0:1/diff(range):Fs-1/diff(range);
end

function [psd_data] = get_PSD_for_all_time_periods(t_map, analog_data, timeVals, good_trial, params, freq_ranges)
    if diff(t_map('Baseline')) ~= diff(t_map('Stimulus'))
        error('baseline and stimulus ranges are not of equal duration');
    elseif diff(t_map('Stimulus')) ~= diff(t_map('Pre_Target'))
        error('Pre_Target and baseline/stimulus ranges are not of equal duration');
    end

    psd_data = struct();

    t_periods = keys(t_map);
    Fs = 1000;
    for key_idx = 1: length(t_map) 
        clear data
        k = t_periods{key_idx};
        range = t_map(k);
        rangePos = round(diff(range)*Fs);

        time_pos = find(timeVals>=range(1),1)+ (1:rangePos);

        % Segmenting data according to timePos
        if strcmp(k, 'Baseline') || strcmp(k, 'Stimulus')
            data = analog_data.stimOnset(good_trial,time_pos)';
        elseif strcmp(k, 'Pre_Target')
            data = analog_data.targetOnset(good_trial,time_pos)';
        end
        [raw_PSD, freqVals] = mtspectrumc(data, params);
        power = get_power(raw_PSD, freqVals, freq_ranges);

        computed = struct();

        computed.raw_psd = raw_PSD;
        computed.freqs = freqVals;
        computed.power = power;

        psd_data.(k) = computed;
    end
end

function [powers] = get_power(raw_PSD, freqVals, freq_ranges)
    for iFreqRange=1:7
        powers{iFreqRange} = getMeanEnergyForAnalysis(raw_PSD, freqVals, freq_ranges{iFreqRange});
    end
end

function get_PSD_trialavg()
    % Segmenting data according to timePos
    dataBL_avg = mean(x.analogData.stimOnset(goodPos_stimOnset,blPos),1)';
    dataStimOnset_avg = mean(x.analogData.stimOnset(goodPos_stimOnset,stPos),1)';
    dataTargetOnset_avg = mean(x.analogData.targetOnset(goodPos_targetOnset,tgPos),1)';
                            
    % power spectral density estimation
    [tmpEBL_avg,~] = mtspectrumc(dataBL_avg,params);
    [tmpEST_avg,~] = mtspectrumc(dataStimOnset_avg,params);
    [tmpETG_avg,~] = mtspectrumc(dataTargetOnset_avg,params);

    
    psdBL_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEBL_avg);
    psdST_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEST_avg);
    psdTG_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpETG_avg);
                            
    for iFreqRange=1:4
        powerValsBL_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEBL_avg,freqVals,freqRanges{iFreqRange}));
        powerValsST_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEST_avg,freqVals,freqRanges{iFreqRange}));
        powerValsTG_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpETG_avg,freqVals,freqRanges{iFreqRange}));
    end
end

function get_TF()
    % computing time-frequency spectrum by
    % multi-taper method (computed for both static
    % and counterphase stimuli)
     [tmpEST_tf,tmpT_tf,freqVals_tf] = mtspecgramc(x.analogData.stimOnset(goodPos_stimOnset,:)',movingwin,params);
     [tmpETG_tf,~,~] = mtspecgramc(x.analogData.targetOnset(goodPos_targetOnset,:)',movingwin,params);
     
     
     timeVals_tf= tmpT_tf + timeVals(1);
     energyST_tf = conv2Log(tmpEST_tf)';
     energyTG_tf = conv2Log(tmpETG_tf)';
     energyBL_tf = mean(energyST_tf(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
     
     mEnergyST_tf(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyST_tf;
     mEnergyTG_tf(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyTG_tf;
     mEnergyBL_tf(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = repmat(energyBL_tf,1,length(timeVals_tf));
end

function get_TF_trialavg()
    % computing time-frequency spectrum by
    % multi-taper method (computed for both static
    % and counterphase stimuli)
    [tmpEST_tf_trialAvg,~,~] = mtspecgramc(mean(x.analogData.stimOnset(goodPos_stimOnset,:),1)',movingwin,params);
    [tmpETG_tf_trialAvg,~,~] = mtspecgramc(mean(x.analogData.targetOnset(goodPos_targetOnset,:),1)',movingwin,params);
    
    
    timeVals_tf= tmpT_tf + timeVals(1);
    energyST_tf_trialAvg = conv2Log(tmpEST_tf_trialAvg)';
    energyTG_tf_trialAvg = conv2Log(tmpETG_tf_trialAvg)';
    energyBL_tf_trialAvg = mean(energyST_tf_trialAvg(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
    
    mEnergyST_tf_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyST_tf_trialAvg;
    mEnergyTG_tf_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyTG_tf_trialAvg;
    mEnergyBL_tf_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = repmat(energyBL_tf_trialAvg,1,length(timeVals_tf));

end

