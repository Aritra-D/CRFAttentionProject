%% runExtractCommonProtocolsHumanEEG
% This program extracts EEG data four common protocols for an
% individual human subject using Brain Products EEG acquisition system
% Common Protocols
% Protocol 1: Eyes Open
% Protocol 2: Eyes Closed
% Protocol 3: GRF protocol- 2 SF (2,4 cpd)- 4 Ori (0-45-90-135) with FS
% and 2 TFs Static Grating (TF=0) and Counterphase (TF=16) -- Stimulus
% induced Alpha and Gamma Response for static and SSVEP response for
% flickering



gridType='EEG'; 
folderSourceString='E:';
folderOutString='E:';

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts] = allCommonProtocolsHumanEEG;

extractAllTheseIndices{1} = 59:60; % Eyes Open and Eyes Closed
extractAllTheseIndices{2} = 62; % GRF protocols



%% Extract Eyes Open and Eyes Closed Protocols
extractTheseIndices = extractAllTheseIndices{1};

for iProt = 1:length(extractTheseIndices)
    
    subjectName = subjectNames{extractTheseIndices(iProt)};
    expDate= expDates{extractTheseIndices(iProt)};
    protocolName= protocolNames{extractTheseIndices(iProt)};
    deviceName = deviceNames{extractTheseIndices(iProt)};
    capLayout = capLayouts{extractTheseIndices(iProt)};
    
% Extraction codes for No-task Protocol from Blackrock can also be 
% incorporated here if EEG is recorded from BlackRock.    
% we can make add extraction codes for no-task/eye-open/eye-closed
% protocols in our lab common programs. For now, it is only for BP.

    if strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')
        fileName = [subjectName expDate protocolName '.vhdr'];
        folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
        makeDirectory(folderName);
        folderIn = fullfile(folderSourceString,'rawData',[subjectName expDate]);
        folderExtract = fullfile(folderName,'extractedData');
        makeDirectory(folderExtract);
        
        % Following code is adapted from getEEGDataBrainProducts under
        % LabCommonPrograms
        % (Programs/CommonPrograms/ReadData/getEEGDataBrainProducts
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
        analysisTimeToBeUsed = 60; % in seconds
        analysisOnsetTimes = 0:1:analysisTimeToBeUsed-1; %goodStimTimes + timeStartFromBaseLine;
        times = eegInfo.times/1000; % This is in ms
        deltaT = 1.000; % in seconds;
        
        if (cAnalog>0)
            
            % Set appropriate time Range
            numSamples = deltaT*Fs;
            timeVals = (1/Fs:1/Fs:deltaT);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Prepare folders
            folderOut = fullfile(folderName,'segmentedData');
            makeDirectory(folderOut); % main directory to store EEG Data
            
            % Make Diectory for storing LFP data
            outputFolder = fullfile(folderOut,'LFP'); % Still kept in the folder LFP to be compatible with Blackrock data
            makeDirectory(outputFolder);
            
            % Now segment and store data in the outputFolder directory
            totalStim = length(analysisOnsetTimes);
            goodStimPos = zeros(1,totalStim);
            for i=1:totalStim
                goodStimPos(i) = find(times>analysisOnsetTimes(i),1);
            end
            
            for i=1:cAnalog
                disp(['elec' num2str(analogInputNums(i))]);
                
                clear analogData
                analogData = zeros(totalStim,numSamples);
                for j=1:totalStim
                    analogData(j,:) = eegInfo.data(analogInputNums(i),goodStimPos(j)+1:goodStimPos(j)+numSamples);
                end
                analogInfo = eegInfo.chanlocs(analogInputNums(i)); %#ok<*NASGU>
                save(fullfile(outputFolder,['elec' num2str(analogInputNums(i)) '.mat']),'analogData','analogInfo');
            end
            
            % Write LFP information. For backward compatibility, we also save
            % analogChannelsStored which is the list of electrode data
            electrodesStored = analogInputNums;
            analogChannelsStored = electrodesStored;
            save(fullfile(outputFolder,'lfpInfo.mat'),'analogChannelsStored','electrodesStored','analogInputNums','goodStimPos','timeVals');
        end
    end
end

%% Extract Standard GRF protocols for SF-Ori Tuning and TF tuning Protocols

% adapted from runExtractAllData
% This is the main program for doing all data extraction.

% Each data file is identified by the following
% 1. subjectName
% 2. expDate - date of the experiment
% 3. protocolName - name of the protocol
% 4. gridType - Microelectrode, ECoG, EEG etc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Once proper data collection begins, a separate file called
% allProtocols{subjectName}{gridType} is created in
% \Programs\DataMAP\SubjectData. This file has a list of three parameters -
% expDate, protocolName and stimType. stimType is a number that describes
% the duration of the signal around each stimulus onset that needs to be
% extracted (given by timeStartFromBaseLineList and deltaTList). The
% following nomenclature is used:

% stimType = 1; % stim On - 200 ms, stim Off - 300 ms. Used for RF mapping
% stimType = 2; % stim On - 400 ms, stim Off - 600 ms.
% stimType = 3; % stim On - 1500 ms, stim Off - 1500 ms.

timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;
timeStartFromBaseLineList(4) = -0.848; deltaTList(4) = 2.048; % stimOn = 0.8; stimOff = 0.7;

timeStartFromBaseLineList(5) = -1; deltaTList(5) = 3.2768; % stimOn = 0.8; stimOff = 0.7;  For BP data with Fs = 2500: Compatible with matching pursuit
timeStartFromBaseLineList(6) = -0.5; deltaTList(6) = 2.048; % stimOn = 0.8; stimOff = 0.7; For BR data (Fs = 2000) and EG Data (Fs = 1000): Compatible with matching pursuit

FsEye=500; % This is set by Lablib, not by the Eye tracking system 
% Eye link Sampling Freq is set at 500 Hz to match with Eye data analysis 
% during eye Data processing in findBadTrialsWithEEG in common Programs
% Also Check Period should be used as function argument in
% findBadTrialsWithEEG as TF tuning protocol in this test data is recorded
% with stim 1500ms and interstim 1500ms.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
extractTheseIndices = extractAllTheseIndices{2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
electrodesToStore = []; % If left empty, all electrodes are stored
auxElectrodesToStore = 1:3; % only for Labjack data
ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode.
frameRate=100;
deltaLimitMS = 1.5; 

deviceName = 'BP'; % BR: Blackrock, BP: BrainProducts, EGI: EGI

for i=1:length(extractTheseIndices)
    
    subjectName = subjectNames{extractTheseIndices(i)};
    expDate = expDates{extractTheseIndices(i)};
    protocolName = protocolNames{extractTheseIndices(i)};
    
    type = stimTypes{extractTheseIndices(i)};
    deltaT = deltaTList(type);
    timeStartFromBaseLine = timeStartFromBaseLineList(type);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Digital Data %%%%%%%%%%%%%%%%%%%%%%%%
    % Step 1 - extract the digital data from a particular data acquisition
    % system. Each data acquisition system has a different program.
    
    folderExtract = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData');
    
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        [hFile,digitalTimeStamps,digitalEvents]=extractDigitalDataBlackrock(subjectName,expDate,protocolName,folderSourceString,gridType);
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        [digitalTimeStamps,digitalEvents]=extractDigitalDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,deltaLimitMS);
    end
    
    % Step 2 - Save digital information in a common format.
    saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Integrate digital information %%%%%%%%%%%%%%%
    % Step 1 - Get Lablib LL Data
    LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType); % Save stimulus information using Lablib data
    
    % Step 2 - extract digital information in a useful format, depending on the protocol.
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        if strncmpi(protocolName,'GRF',3)
            [goodStimNums,goodStimTimes,activeSide]=extractDigitalDataGRF(folderExtract,ignoreTargetStimFlag,frameRate);
        end
        if LLFileExistsFlag
            matchingParameters=compareLLwithNEV(folderExtract,activeSide,1); % Compare Lablib and digital file. If digital codes for stimulus paramaters are not sent, extract that information from Lablib
            saveEyePositionAndBehaviorData(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
        end
        
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        if LLFileExistsFlag
            if strncmpi(protocolName,'GRF',3)
                displayTSTEComparison(folderExtract); % In case, TE Codes not available; commenting out this line will extract the data.
                [goodStimNums,goodStimTimes,activeSide]=extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);
            end
            saveEyePositionAndBehaviorData(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,ignoreTargetStimFlag); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
        else
            error('With BrainProducts, digital codes cannot be obtained without Lablib File...');
        end
    end
    
    % Step 3 - generate 'parameterCombinations' that allows us to find the
    % useful combinations
    if strncmpi(protocolName,'GRF',3)
        getDisplayCombinationsGRF(folderExtract,goodStimNums);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Save Analog and Spike Data %%%%%%%%%%%%%%%%%%%%%%
    
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        
        Fs=2000;
        analogChannelsToStore = electrodesToStore;
        neuralChannelsToStore = analogChannelsToStore;
        getLFP=1;getSpikes=0;
        
        getLFPandSpikesBlackrock(subjectName,expDate,protocolName,folderSourceString,gridType,analogChannelsToStore,neuralChannelsToStore,...
            goodStimTimes,timeStartFromBaseLine,deltaT,Fs,hFile,getLFP,getSpikes);
        
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        
        getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
        %         getAuxDataLabjack(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,auxElectrodesToStore);
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Find Bad Trials %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    % one minor change needs to be done on findBadTrialsWithEEG protocol
    % added a condition to convert eyeDataDegX and eyeDataDegY cells into
    % arrays only if they are cells. 
    
    % [badTrials,allBadTrials,badTrialsUnique,badElecs,totalTrials,slopeValsVsFreq] =...
    % findBadTrialsWithEEG(subjectName,expDate,protocolName,folderSourceString,gridType,...
    % badEEGElectrodes,nonEEGElectrodes,impedanceTag,capType,saveDataFlag,badTrialNameStr,...
    % displayResultsFlag)
    nonEEGElectrodes =  [65 66];
    findBadTrialsWithEEG(subjectName,expDate,protocolName,folderSourceString,gridType,[],...
      nonEEGElectrodes,'ImpedanceStart','actiCap64',1,'_v5',0)
end