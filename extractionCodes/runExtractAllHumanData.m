% runExtractAllHumanData
% This is the main program for doing all data extraction.

% clear Workspace and close already opened figures
clear; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each data file is identified by the following
% 1. projectName
% 2. expDate - date of the experiment
% 3. protocolName - name of the protocol
% 4. gridType - Microelectrode, ECoG, EEG etc

% Once proper data collection begins, a separate file called
% allProtocols{projectName}{gridType} is created in
% \Programs\DataMAP\SubjectData\gridType. This file has a list of six parameters -
% subjectName, expDate, protocolName, stimType, deviceName and capLayout.

projectName = 'CRFAttention'; gridType = 'EEG'; protocolType = 'OldData'; folderSourceString = fullfile('E:\data\human',protocolType);
% subjectName = 'test'; gridType = 'EEG'; folderSourceString = 'E:';

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType 'v1']);
% [subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,protocolTypes] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType]);
% [expDates,protocolNames,stimTypes] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);% getAllProtocols(subjectName,gridType);

% stimType is a number that describes the duration of the signal around
% each stimulus onset that needs to be extracted (given by
% timeStartFromBaseLineList and deltaTList). For details, see stimTypeList
[timeStartFromBaseLineList,deltaTList] = stimTypeList;

% [sfList,oriList] = eval(['allProtocolDetails' upper(projectName(1)) projectName(2:end) gridType]);
% extractTheseIndices = unique([sfList(:);oriList(:)]);

extractTheseIndices = 464:466;%[461 462];  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FsEye=500; % This is set by Lablib, not by the Eye tracking system; for BP recording with Eyelink, we set FsEye at 500 Hz in Lablib.
electrodesToStore = []; % If left empty, all electrodes are stored
ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
frameRate=100;
deltaLimitMS = 1.3;

for i=1:length(extractTheseIndices)
    
    tic;
    subjectName = subjectNames{extractTheseIndices(i)};
    expDate = expDates{extractTheseIndices(i)};
    protocolName = protocolNames{extractTheseIndices(i)};
    deviceName = deviceNames{extractTheseIndices(i)};
    capLayout = capLayouts{extractTheseIndices(i)};
%     
    type = stimTypes{extractTheseIndices(i)};
    deltaT = deltaTList(type);
    timeStartFromBaseLine = timeStartFromBaseLineList(type);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Digital Data %%%%%%%%%%%%%%%%%%%%%%%%
    % Step 1 - extract the digital data from a particular data acquisition
    % system. Each data acquisition system has a different program. 
    
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
    folderExtract = fullfile(folderName,'extractedData');
    makeDirectory(folderName);
    diary(fullfile(folderName,'ExtractionReport.txt'));

    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        [hFile,digitalTimeStamps,digitalEvents]=extractDigitalDataBlackrock(subjectName,expDate,protocolName,folderSourceString,gridType);
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        [digitalTimeStamps,digitalEvents]=extractDigitalDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,deltaLimitMS);
    end
    
    % Step 2 - Save digital information in a common format.
    saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Integrate digital information %%%%%%%%%%%%%%%
    % Step 2.1 - Get Lablib LL Data
    LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType,frameRate); % Save stimulus information using Lablib data
    
    % Step 2.2 - extract digital information in a useful format, depending on the protocol.
    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        if strncmpi(protocolName,'GRF',3) || strncmpi(protocolName,'GAV',3)
            [goodStimNums,goodStimTimes,activeSide]=extractDigitalDataGRF(folderExtract,ignoreTargetStimFlag,frameRate);
            if LLFileExistsFlag
                matchingParameters=compareLLwithNEV(folderExtract,activeSide,1); % Compare Lablib and digital file. If digital codes for stimulus paramaters are not sent, extract that information from Lablib
            end
        elseif strncmpi(protocolName,'SRC',3)
            displayTSTEComparison(folderExtract);
            [goodStimNums,goodStimTimes]=extractDigitalDataSRCLL(folderExtract); % For SRC protocol, get all stimulus information from LL file
        end
        
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        if LLFileExistsFlag
            if strncmpi(protocolName,'GRF',3)
                displayTSTEComparison(folderExtract);
                [goodStimNums,goodStimTimes,activeSide]=extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);
            elseif strncmpi(protocolName,'SRC',3)
                maxDiffTrialStartTimePercent = displayTSTEComparison(folderExtract);
                [goodStimNums,goodStimTimes]=extractDigitalDataSRCLL(folderExtract);
            elseif strncmpi(protocolName,'GAV',3)
                displayTSTEComparison(folderExtract);
                [goodStimNums,goodStimTimes,activeSide]=extractDigitalDataGRFLL(folderExtract,ignoreTargetStimFlag,frameRate);
            end
        else
            error('With BrainProducts, digital codes cannot be obtained without Lablib File...');
        end
    end
    
    % Step 2.3 - Get Eye Position and Behavior Data
    if LLFileExistsFlag
       saveEyePositionAndBehaviorData(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,ignoreTargetStimFlag); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
    end
    
    % Step 3 - generate 'parameterCombinations' that allows us to find the
    % useful combinations
    if strncmpi(protocolName,'GRF',3)
        getDisplayCombinationsGRF(folderExtract,goodStimNums);
    elseif strncmpi(protocolName,'SRC',3)
        getDisplayCombinationsSRC(folderExtract,goodStimNums);
    elseif strncmpi(protocolName,'GAV',3)
        getDisplayCombinationsGRF(folderExtract,goodStimNums);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Save Analog and Spike Data %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmpi(deviceName,'BR') || strcmpi(deviceName,'Blackrock')        % Blackrock
        
        Fs=2000;
        analogChannelsToStore = electrodesToStore;
        neuralChannelsToStore = analogChannelsToStore;
        getLFP=1;getSpikes=0;

        getLFPandSpikesBlackrock(subjectName,expDate,protocolName,folderSourceString,gridType,analogChannelsToStore,neuralChannelsToStore,...
            goodStimTimes,timeStartFromBaseLine,deltaT,Fs,hFile,getLFP,getSpikes);
        
    elseif strcmpi(deviceName,'BP') || strcmpi(deviceName,'BrainProducts')  % BrainProducts
        if ~isstruct(goodStimTimes) % GRF Protocols and SRC-Short Protocols (SRCType = 1)
            getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
            if strcmp(protocolName(1:3),'GRF')
                SRCType = 0;
            elseif strcmp(protocolName(1:3),'SRC')
                SRCType = 1;
            end
        elseif isstruct(goodStimTimes) && isfield(goodStimTimes,'stimOnset') && isfield(goodStimTimes,'targetOnset') % SRC-Long Protocols (SRCType = 2)
            getEEGDataBrainProductsSRCLong(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT);
            SRCType = 2;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Find Bad Trials %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % [badTrials,allBadTrials,badTrialsUnique,badElecs,totalTrials,slopeValsVsFreq] =...
    % findBadTrialsWithEEG(subjectName,expDate,protocolName,folderSourceString,gridType,...
    % badEEGElectrodes,nonEEGElectrodes,impedanceTag,capType,saveDataFlag,badTrialNameStr,...
    % displayResultsFlag)
    nonEEGElectrodes =  [65 66];
        if SRCType == 0 || SRCType == 1 % GRF Protocols and SRC-Short Protocols (SRCType = 1)
            findBadTrialsWithEEG(subjectName,expDate,protocolName,folderSourceString,gridType,[],...
                nonEEGElectrodes,'ImpedanceStart','actiCap64',1,'_v5',0);
        elseif SRCType == 2 % SRC-Long Protocols (SRCType = 2)
            findBadTrialsWithEEG_SRCLong(subjectName,expDate,protocolName,folderSourceString,gridType,[],...
                nonEEGElectrodes,'ImpedanceStart','actiCap64',1,'_v5',0);
        end
   
    % Save a log of the extraction for further analyses
    dataLog{1,1}='subjectName';           dataLog{1,2} = subjectName;
    dataLog{2,1}='gridType';              dataLog{2,2} = gridType;
    dataLog{3,1}='expDate';               dataLog{3,2} = expDate;
    dataLog{4,1}='protocolName';          dataLog{4,2} = protocolName;
    dataLog{5,1}='timeStartFromBaseLine'; dataLog{5,2}=timeStartFromBaseLine;
    dataLog{6,1}='deltaT';                dataLog{6,2}=deltaT;  
    dataLog{7,1}='electrodesToStore';
    dataLog{8,1}='badTrials';
    dataLog(9,1)=cellstr('elecSampleRate');
    dataLog(10,1)=cellstr('AinpSampleRate');
    
    % Load LFP Info
    folderLFP = fullfile(folderName,'SegmentedData\LFP\');
    fileName = fullfile(folderLFP,'lfpInfo.mat');
    if exist(fileName,'file')
    load(fileName); 
    else
        error('LFPInfo file not Found!')
    end
        
    if strcmp(deviceName,'BR')
        dataLog{7,2}=electrodesStored;
        dataLog{9,2}= round(1/(timeVals(2)-timeVals(1)));
        dataLog{10,2}= round(1/(timeVals(2)-timeVals(1)));
    elseif strcmp(deviceName,'BP')
        dataLog{7,2}=electrodesStored;
        dataLog{9,2}=round(1/(timeVals(2)-timeVals(1)));
        dataLog{10,2}=round(1/(timeVals(2)-timeVals(1)));
    end
    
    folderSegment = fullfile(folderName,'SegmentedData');
    badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
    if exist(badTrialFile,'file')
        load(badTrialFile);
        dataLog(8,2)={badTrials};
    else
        dataLog(8,2)= [];
    end

    dataLog{11,1}='LLData';    dataLog{11,2}='YES';   
    dataLog{12,1}='LLExtract'; dataLog{12,2}='YES';    
    dataLog{13,1}='Reallign';  dataLog{13,2}='NO';
 
    dataLog{14,1} = 'folderSourceString_rawData';
    dataLog{14,2}.rawDataFolder = 'NeoLabData\rawData\human\CRFAttention\CRFAttentionProject';
    dataLog{14,2}.extractedDataFolder = folderSourceString;

    dataLog{15,1} = 'Montage';          dataLog{15,2} = capLayout;
    dataLog{16,1} = 'Re-Ref Elec';      dataLog{16,2} = 'None';
    
    save(fullfile(folderName,'dataLog.mat'), 'dataLog');
    dataLog %#ok<NOPTS>
        
    elapsedTime = toc/60;
    disp(['Total time taken for extraction: ' num2str(elapsedTime) ' min.']);
    disp(['Extraction report saved to ' folderName '\ExtractionReport.txt']);
    diary('off');

end