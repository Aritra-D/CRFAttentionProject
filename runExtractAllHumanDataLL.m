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


subjectName = 'AD'; expDate = '161121'; protocolName = 'SRC_001';
gridType = 'EEG';
deviceName = 'BP';
folderSourceString = 'E:\';

[timeStartFromBaseLineList,deltaTList] = stimTypeList;

FsEye = 500; % This is set by Lablib, not by the Eye tracking system; for BP recording with Eyelink, we set FsEye at 500 Hz in Lablib.
electrodesToStore = []; % If left empty, all electrodes are stored
ignoreTargetStimFlag=1; % For GaborRFMap stimuli, set this to 1 if the program is run in the fixation mode. 
frameRate=100;
deltaLimitMS = 1.2;

% Step 2.1 - Get Lablib LL Data
LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType,frameRate); % Save stimulus information using Lablib data

% Step 2.3 - Get Eye Position and Behavior Data
if LLFileExistsFlag
    saveEyePositionAndBehaviorData_newSRC(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,ignoreTargetStimFlag); % As of now this works only if Target and Mapping stimuli have the same duration and ISI
end
