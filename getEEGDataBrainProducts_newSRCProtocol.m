% This program extracts EEG data from the raw (.eeg, .vhdr, .vmrk) files
% and stores the data in specified folders. The format is the same as for Blackrock data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program needs the following matlab files
% makeDirectory.m
% appendIfNotPresent.m
% removeIfPresent.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Supratim Ray,
% March 2015

function getEEGDataBrainProducts_newSRCProtocol(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [subjectName expDate protocolName '.vhdr'];
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use EEGLAB plugin "bva-io" to read the file
eegInfo = pop_loadbv(folderIn,fileName,[],[]);

cAnalog = eegInfo.nbchan;
Fs = eegInfo.srate;
analogInputNums = 1:cAnalog;
disp(['Total number of Analog channels recorded: ' num2str(cAnalog)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% EEG Decomposition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


analysisOnsetTimes{1} = goodStimTimes.stimOnset + timeStartFromBaseLine; % 1-StimOnset
analysisOnsetTimes{2} = goodStimTimes.targetOnset + timeStartFromBaseLine; % 2-TargetOnset
times = eegInfo.times/1000; % This is in ms

if (cAnalog>0)
    
    % Set appropriate time Range
    numSamples = deltaT*Fs;
    timeVals = timeStartFromBaseLine+ (1/Fs:1/Fs:deltaT);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare folders
    folderOut = fullfile(folderName,'segmentedData');
    makeDirectory(folderOut); % main directory to store EEG Data
    
    % Make Diectory for storing LFP data
    outputFolder = fullfile(folderOut,'LFP'); % Still kept in the folder LFP to be compatible with Blackrock data
    makeDirectory(outputFolder);
    
    % Now segment and store data in the outputFolder directory
    if length(analysisOnsetTimes{1})==length(analysisOnsetTimes{2})
        totalStim = length(analysisOnsetTimes{1});
    else
        error('Length of StimNums and TargetNums is unequal')
    end
    
    goodStimPos.stimOnset = zeros(1,totalStim);
    for i=1:totalStim
        goodStimPos.stimOnset(i) = find(times>analysisOnsetTimes{1}(i),1);
        goodStimPos.targetOnset(i) = find(times>analysisOnsetTimes{2}(i),1);
    end
    
    for i=1:cAnalog
        disp(['elec' num2str(analogInputNums(i))]);
        
        clear analogData analogData_stimOnset analogData_targetOnset
        analogData_stimOnset = zeros(totalStim,numSamples);
        analogData_targetOnset = zeros(totalStim,numSamples);
        for j=1:totalStim
            analogData_stimOnset(j,:) = eegInfo.data(analogInputNums(i),goodStimPos.stimOnset(j)+1:goodStimPos.stimOnset(j)+numSamples);
            analogData_targetOnset(j,:) = eegInfo.data(analogInputNums(i),goodStimPos.targetOnset(j)+1:goodStimPos.targetOnset(j)+numSamples);
        end
        analogData.stimOnset = analogData_stimOnset;
        analogData.targetOnset = analogData_targetOnset;
        analogInfo = eegInfo.chanlocs(analogInputNums(i)); %#ok<*NASGU>
        save(fullfile(outputFolder,['elec' num2str(analogInputNums(i)) '.mat']),'analogData','analogInfo');
    end
    
    
    % Write LFP information. For backward compatibility, we also save
    % analogChannelsStored which is the list of electrode data
    electrodesStored = analogInputNums;
    analogChannelsStored = electrodesStored;
    save(fullfile(outputFolder,'lfpInfo.mat'),'analogChannelsStored','electrodesStored','analogInputNums','goodStimPos','timeVals');
end
