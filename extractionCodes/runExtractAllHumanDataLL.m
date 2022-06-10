% runExtractAllHumanDataLL
% This is the main program for doing all data extraction.

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


projectName = 'CRFAttention'; gridType = 'EEG'; folderSourceString = 'E:\data\human\SRCLong';
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType]);

% stimType is a number that describes the duration of the signal around
% each stimulus onset that needs to be extracted (given by
% timeStartFromBaseLineList and deltaTList). For details, see stimTypeList
[timeStartFromBaseLineList,deltaTList] = stimTypeList;

extractTheseIndices = [247 249 251];

FsEye = 200; % This is set by Lablib, not by the Eye tracking system; for BP recording with Eyelink, we set FsEye at 500 Hz in Lablib.
electrodesToStore = []; % If left empty, all electrodes are stored
ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
frameRate=100;
deltaLimitMS = 1.3;

for i=1:length(extractTheseIndices)
    close all;
    tic;
    subjectName = subjectNames{extractTheseIndices(i)};
    expDate = expDates{extractTheseIndices(i)};
    protocolName = protocolNames{extractTheseIndices(i)};
    deviceName = deviceNames{extractTheseIndices(i)};
    capLayout = capLayouts{extractTheseIndices(i)};
    type = stimTypes{extractTheseIndices(i)};
    deltaT = deltaTList(type);
    timeStartFromBaseLine = timeStartFromBaseLineList(type);
    
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
    folderExtract = fullfile(folderName,'extractedData');
    makeDirectory(folderName);
    diary(fullfile(folderName,'ExtractionReport.txt'));
    
    
    % Step 2.1 - Get Lablib LL Data
    LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType,frameRate); % Save stimulus information using Lablib data
    
    % Step 2.3 - Get Eye Position and Behavior Data
    if LLFileExistsFlag
        saveEyePositionAndBehaviorData(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,ignoreTargetStimFlag); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
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
        if strcmp(deviceName,'BP')
            dataLog{7,2}=[];
            dataLog{9,2}=[];
            dataLog{10,2}=[];
        end
    end
        
    folderSegment = fullfile(folderName,'SegmentedData');
    badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
    if exist(badTrialFile,'file')
        load(badTrialFile);
        dataLog(8,2)={badTrials};
    else
        dataLog(8,2)= {[]};
    end

    dataLog{11,1}='LLData';    dataLog{11,2}='YES';   
    dataLog{12,1}='LLExtract'; dataLog{12,2}='YES';    
    dataLog{13,1}='Reallign';  dataLog{13,2}='NO';
 
    dataLog{14,1} = 'folderSourceString_rawData';
    dataLog{14,2}.rawDataFolder = 'NeoLabData\rawData\human\CRFAttention\CRFAttentionProject';
    dataLog{14,2}.extractedDataFolder = folderSourceString;

    dataLog{15,1} = 'Montage';          dataLog{15,2} = 'NA';
    dataLog{16,1} = 'Re-Ref Elec';      dataLog{16,2} = 'NA';
    
    save(fullfile(folderName,'dataLog.mat'), 'dataLog');
    dataLog %#ok<NOPTS>
        
    elapsedTime = toc/60;
    disp(['Total time taken for extraction: ' num2str(elapsedTime) ' min.']);
    disp(['Extraction report saved to ' folderName '\ExtractionReport.txt']);
    diary('off');

end