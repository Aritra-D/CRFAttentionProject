% This program contained the following functions from the old format
% 1. saveLLDataSRC and saveLLDataGRF
% 2. getStimResultsLLSRC and getStimResultsLLGRF
% 3. saveEyeAndBehaviorDataSRC and saveEyeAndBehaviorDataGRF
% 4. getEyePositionAndBehavioralDataSRC and getEyePositionAndBehavioralDataGRF

% 5. saveEyeDataInDegSRC, saveEyeDataInDeg (GRF suffix added),
% saveEyeDataStimPosGRF and getEyeDataStimPosGRF

% Now it only contains 1, the remining ones (2-5) are in a separate program
% (saveEyePositionAndBehaviorData)

% 10 March 2015: More information is extracted from LL data file because
% the digital codes are no longer sufficient for EEG data

% 19 March 2015: Adding endTime (trialEnd) in GRF.
% 9th October 2015: Adding endTime and trialCertify in SRC.

function LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType,frameRate,folderDestinationString)

if ~exist('folderDestinationString','var'); folderDestinationString=folderSourceString; end
if ~exist('frameRate','var'); frameRate=100; end

datFileName = fullfile(folderSourceString,'data','rawData',subjectName,[subjectName expDate],[subjectName expDate protocolName '.dat']);

if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'data','rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

if ~exist(datFileName,'file')
    disp('Lablib data file does not exist');
    LLFileExistsFlag = 0;
else
    disp('Working on Lablib data file ...');
    LLFileExistsFlag = 1;
    folderName    = fullfile(folderDestinationString,'data',subjectName,gridType,expDate,protocolName);
    folderExtract = fullfile(folderName,'extractedData');
    makeDirectory(folderExtract);
    
    if strncmpi(protocolName,'SRC',3) % SRC
        [LL,targetInfo,psyInfo,reactInfo,newSRCFlag] = getStimResultsLLSRC(subjectName,expDate,protocolName,folderSourceString,frameRate); %#ok<*ASGLU,*NASGU>
        save(fullfile(folderExtract,'LL.mat'),'LL','targetInfo','psyInfo','reactInfo','newSRCFlag');
    else
        LL = getStimResultsLLGRF(subjectName,expDate,protocolName,folderSourceString);
        save(fullfile(folderExtract,'LL.mat'),'LL');
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LL,targetInfo,psyInfo,reactInfo,newSRCFlag] = getStimResultsLLSRC(subjectName,expDate,protocolName,folderSourceString,frameRate)

frameISIinMS=1000/frameRate;

datFileName = fullfile(folderSourceString,'data','rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

% Get Lablib data
header = readLLFile('i',datFileName);

if isfield(header,'eccentricityDeg')
    LL.azimuthDeg   = round(100*header.eccentricityDeg.data*cos(header.polarAngleDeg.data/180*pi))/100;
    LL.elevationDeg = round(100*header.eccentricityDeg.data*sin(header.polarAngleDeg.data/180*pi))/100;
elseif isfield(header,'azimuthDeg')
    LL.azimuthDeg   = header.azimuthDeg.data;
    LL.elevationDeg = header.elevationDeg.data;
elseif isfield(header,'azimuth0Deg')
    LL.azimuth0Deg   = header.azimuth0Deg.data;
    LL.elevation0Deg = header.elevation0Deg.data;
    LL.azimuth1Deg   = header.azimuth1Deg.data;
    LL.elevation1Deg = header.elevation1Deg.data;
end

LL.sigmaDeg = header.sigmaDeg.data;
if isfield(header,'radiusDeg')
    LL.radiusDeg = header.radiusDeg.data;
end

if isfield(header,'spatialFreqCPD')
    LL.spatialFreqCPD = header.spatialFreqCPD.data;
elseif isfield(header,'spatialFreq0CPD')
    LL.spatialFreq0CPD = header.spatialFreq0CPD.data;
    LL.spatialFreq1CPD = header.spatialFreq1CPD.data;
end

if isfield(header,'stimOrientationDeg')
    LL.orientationDeg = header.stimOrientationDeg.data;
elseif isfield(header,'stimOrientation0Deg')
    LL.baseOrientation0Deg = header.stimOrientation0Deg.data;
    LL.baseOrientation1Deg = header.stimOrientation1Deg.data;
end

% Trial properties
numTrials = header.numberOfTrials;
targetContrastIndex = [];
targetTemporalFreqIndex = [];
targetContrastIndex_stimDesc = [];
targetTemporalFreqIndex_stimDesc = [];
catchTrial = [];
instructTrial = [];
attendLoc = [];
eotCode = [];
startTime = [];
endTime = [];
trialCertify = [];

% Added for new SRC
newSRCFlag = 0;
changeInOrientation = [];
targetIndex = [];

% Stimulus Properties
allStimulusOnTimes = [];
stimType0 = [];
stimType1 = [];
contrastIndex = [];
temporalFreqIndex = [];
contrast0PC = [];
contrast1PC = [];
orientation0Deg = [];
orientation1Deg = [];
temporalFreq0Hz = [];
temporalFreq1Hz = [];

countTI=1;
countPI=1;
countRI=1;

for i=1:numTrials
    disp(['trial ' num2str(i) ' of ' num2str(numTrials)]);
    clear trials
    trials = readLLFile('t',i);
    
    if isfield(trials,'trialStart')
        startTime = cat(2,startTime,[trials.trialStart.timeMS]);
    end
    
    if isfield(trials,'trialCertify')
        trialCertify = [trialCertify [trials.trialCertify.data]];
    end
    
    if isfield(trials,'trialEnd')
        thisEOT = [trials.trialEnd.data];
        eotCode = [eotCode thisEOT];
        endTime = [endTime [trials.trialEnd.timeMS]];
    end
    
    if isfield(trials,'stimulusOn')
        allStimulusOnTimes = [allStimulusOnTimes [trials.stimulusOn.timeMS]'];
    end
    
    if isfield(trials,'stimDesc')
        stimType0 = [stimType0 [trials.stimDesc.data.type0]];
        stimType1 = [stimType1 [trials.stimDesc.data.type1]];
        contrastIndex = [contrastIndex [trials.stimDesc.data.contrastIndex]];
        temporalFreqIndex = [temporalFreqIndex [trials.stimDesc.data.temporalFreqIndex]];
        contrast0PC = [contrast0PC [trials.stimDesc.data.contrast0PC]];
        contrast1PC = [contrast1PC [trials.stimDesc.data.contrast1PC]];
        orientation0Deg = [orientation0Deg [trials.stimDesc.data.orientation0Deg]];
        orientation1Deg = [orientation1Deg [trials.stimDesc.data.orientation1Deg]];
        temporalFreq0Hz = [temporalFreq0Hz [trials.stimDesc.data.temporalFreq0Hz]];
        temporalFreq1Hz = [temporalFreq1Hz [trials.stimDesc.data.temporalFreq1Hz]];
    end
    
    if isfield(trials,'trial')
        thisTrialData = trials.trial.data;
        thisCatchTrial    = [thisTrialData.catchTrial];
        thisInstructTrial = [thisTrialData.instructTrial];
        thisAttendLoc     = [thisTrialData.attendLoc];
        thisTargetContrastIndex     = [thisTrialData.targetContrastIndex];
        thisTargetTemporalFreqIndex = [thisTrialData.targetTemporalFreqIndex];
        
        if isfield(trials,'stimDesc')
            if thisCatchTrial == 1
                thisTargetContrastIndex_stimDesc = -1;
                thisTargetTemporalFreqIndex_stimDesc = -1;
            else
                if thisTrialData.targetIndex+1 > length(trials.stimDesc.data)
                    thisTargetContrastIndex_stimDesc = NaN;
                    thisTargetTemporalFreqIndex_stimDesc = NaN;
                else
                    
                    thisTargetContrastIndex_stimDesc = trials.stimDesc.data(thisTrialData.targetIndex+1).contrastIndex;
                    thisTargetTemporalFreqIndex_stimDesc = trials.stimDesc.data(thisTrialData.targetIndex+1).temporalFreqIndex;
                end
            end
        else
            thisTargetContrastIndex_stimDesc = NaN;
            thisTargetTemporalFreqIndex_stimDesc = NaN;
        end
%         if isfield(trials,'stimDesc')
%             if thisCatchTrial == 1
%                 thisTargetTemporalFreqIndex = -1;
%             else
%                 if thisTrialData.targetIndex+1 > length(trials.stimDesc.data)
%                     thisTargetTemporalFreqIndex = NaN;
%                 else
%                 thisTargetTemporalFreqIndex = trials.stimDesc.data(thisTrialData.targetIndex+1).temporalFreqIndex;%unique([trials.stimDesc.data.temporalFreqIndex]);
%                 end
%             end
%         else
%         thisTargetTemporalFreqIndex = Inf;
%         end
        
        if isfield(thisTrialData,'changeInOrientationTF2')
            newSRCFlag=1;
        else
            newSRCFlag=0;
        end
        
        if newSRCFlag
            if isfield(thisTrialData,'targetIndex')
                thisTargetIndex = [thisTrialData.targetIndex];
            else
                thisTargetIndex = [];
            end
            
            if thisTargetTemporalFreqIndex==0
                thisChangeInOrientation = thisTrialData.changeInOrientation;
            elseif thisTargetTemporalFreqIndex==1
                thisChangeInOrientation = thisTrialData.changeInOrientationTF1;
            elseif thisTargetTemporalFreqIndex==2
                thisChangeInOrientation = thisTrialData.changeInOrientationTF2;
            elseif thisTargetTemporalFreqIndex==-1 % Catch trial
                thisChangeInOrientation = 0;
            elseif isnan(thisTargetTemporalFreqIndex) || isinf(thisTargetTemporalFreqIndex)
                thisChangeInOrientation = thisTrialData.changeInOrientation;
            else
                error('Number of temporal frequencies must be 3');
            end
        end
        
        catchTrial    = cat(2,catchTrial,thisCatchTrial);
        instructTrial = cat(2,instructTrial,thisInstructTrial);
        attendLoc     = cat(2,attendLoc,thisAttendLoc);
        
        targetContrastIndex    = cat(2,targetContrastIndex,thisTargetContrastIndex);
        targetTemporalFreqIndex = cat(2,targetTemporalFreqIndex,thisTargetTemporalFreqIndex);
        
        targetContrastIndex_stimDesc    = cat(2,targetContrastIndex_stimDesc,thisTargetContrastIndex_stimDesc);
        targetTemporalFreqIndex_stimDesc = cat(2,targetTemporalFreqIndex_stimDesc,thisTargetTemporalFreqIndex_stimDesc);
        
        if newSRCFlag
            targetIndex = cat(2,targetIndex,thisTargetIndex);
            changeInOrientation = cat(2,changeInOrientation,thisChangeInOrientation);
        end
        % Adding the getTrialInfoLLFile (from the MAC) details here
        
        % Nothing to update on catch trials or instruction trials
        if (thisCatchTrial) || (thisInstructTrial) %#ok<*BDSCI,BDLGI>
            % Do nothing
        else
            
            % All the information needed to plot the targetIndex versus
            % performace plot are stored in the variable targetInfo
            
            targetInfo(countTI).trialNum          = i; %#ok<*AGROW>
            targetInfo(countTI).contrastIndex     = thisTargetContrastIndex;
            targetInfo(countTI).temporalFreqIndex = thisTargetTemporalFreqIndex;
            targetInfo(countTI).targetIndex       = trials.trial.data.targetIndex;
            targetInfo(countTI).contrastIndex_stimDesc     = thisTargetContrastIndex_stimDesc;
            targetInfo(countTI).temporalFreqIndex_stimDesc = thisTargetTemporalFreqIndex_stimDesc;
            targetInfo(countTI).attendLoc         = thisAttendLoc;
            targetInfo(countTI).eotCode           = thisEOT;
            targetInfo(countTI).trialCertify      = trials.trialCertify.data;
            
            if newSRCFlag
                targetInfo(countTI).targetIndex       = thisTargetIndex;
                targetInfo(countTI).changeInOrientation = thisChangeInOrientation;
            end
            countTI=countTI+1;
            
            % In addition, if the EOTCODE is correct, wrong or failed, make
            % another variable 'psyInfo' that stores information to plot the
            % psychometric functions
            
            if thisEOT <=2 % Correct, wrong or failed
                psyInfo(countPI).trialNum          = i;
                psyInfo(countPI).contrastIndex     = thisTargetContrastIndex;
                psyInfo(countPI).temporalFreqIndex = thisTargetTemporalFreqIndex;
                psyInfo(countPI).contrastIndex_stimDesc     = thisTargetContrastIndex_stimDesc;
                psyInfo(countPI).temporalFreqIndex_stimDesc = thisTargetTemporalFreqIndex_stimDesc;
                psyInfo(countPI).attendLoc         = thisAttendLoc;
                psyInfo(countPI).eotCode           = thisEOT;
                psyInfo(countPI).trialCertify      = trials.trialCertify.data;
            
                if newSRCFlag
                    psyInfo(countPI).targetIndex         = thisTargetIndex;
                    psyInfo(countPI).changeInOrientation = thisChangeInOrientation;
                end
                countPI=countPI+1;
            end
            
            % Finally, get the reaction times for correct trials and store them
            % in 'reactInfo'
            
            if thisEOT==0
                reactInfo(countRI).trialNum          = i;
                reactInfo(countRI).contrastIndex     = thisTargetContrastIndex;
                reactInfo(countRI).temporalFreqIndex = thisTargetTemporalFreqIndex;
                reactInfo(countRI).contrastIndex_stimDesc     = thisTargetContrastIndex_stimDesc;
                reactInfo(countRI).temporalFreqIndex_stimDesc = thisTargetTemporalFreqIndex_stimDesc;

                reactInfo(countRI).attendLoc         = thisAttendLoc;
                reactInfo(countRI).reactTime         = trials.saccade.timeMS-trials.visualStimsOn.timeMS ...
                                                       -trials.stimulusOn.data(trials.trial.data.targetIndex+1)*frameISIinMS;
                reactInfo(countRI).trialCertify      = trials.trialCertify.data;

                if newSRCFlag
                    reactInfo(countRI).targetIndex         = thisTargetIndex;
                    reactInfo(countRI).changeInOrientation = thisChangeInOrientation;
                end
                countRI=countRI+1;
            end
        end
    end
end

LL.eotCode = eotCode;
LL.instructTrial = instructTrial;
LL.catchTrial = catchTrial;
LL.attendLoc = attendLoc;
LL.targetContrastIndex = targetContrastIndex;
LL.targetTemporalFreqIndex = targetTemporalFreqIndex;
LL.targetContrastIndex_stimDesc = targetContrastIndex_stimDesc;
LL.targetTemporalFreqIndex_stimDesc = targetTemporalFreqIndex_stimDesc;
LL.startTime = startTime/1000; % in seconds
LL.endTime = endTime/1000; % in seconds
LL.trialCertify = trialCertify;

if newSRCFlag
    LL.changeInOrientation = changeInOrientation;
    LL.targetIndex = targetIndex;
end

% Stimlus Properties
LL.stimOnTimes = allStimulusOnTimes;
LL.stimType0 = stimType0;
LL.stimType1 = stimType1;
LL.contrastIndex = contrastIndex;
LL.temporalFreqIndex = temporalFreqIndex;
LL.contrast0PC = contrast0PC;
LL.contrast1PC = contrast1PC;
LL.orientation0Deg = orientation0Deg;
LL.orientation1Deg = orientation1Deg;
LL.temporalFreq0Hz = temporalFreq0Hz;
LL.temporalFreq1Hz = temporalFreq1Hz;
end
function LL = getStimResultsLLGRF(subjectName,expDate,protocolName,folderSourceString)

datFileName = fullfile(folderSourceString,'data','rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);

if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'data','rawData',subjectName,[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

% Get Lablib data
header = readLLFile('i',datFileName);

% Stimulus properties
numTrials = header.numberOfTrials;

allStimulusIndex = [];
allStimulusOnTimes = [];
gaborIndex = [];
stimType = [];
azimuthDeg = [];
elevationDeg = [];
sigmaDeg = [];
radiusDeg = [];
spatialFreqCPD =[];
orientationDeg = [];
contrastPC = [];
temporalFreqHz = [];

eotCode=[];
myEotCode=[];
endTime=[];
startTime=[];
instructTrial=[];
catchTrial=[];
trialCertify=[];

for i=1:numTrials
    disp(['trial ' num2str(i) ' of ' num2str(numTrials)]);
    clear trials
    trials = readLLFile('t',i);
    
    if isfield(trials,'trial')
        instructTrial = [instructTrial [trials.trial.data.instructTrial]];
        catchTrial    = [catchTrial [trials.trial.data.catchTrial]];
    end
    
    if isfield(trials,'trialCertify')
        trialCertify = [trialCertify [trials.trialCertify.data]];
    end
    
    if isfield(trials,'trialEnd')
        eotCode = [eotCode [trials.trialEnd.data]];
        endTime = [endTime [trials.trialEnd.timeMS]];
    end
    
    if isfield(trials,'myTrialEnd')
        myEotCode = [myEotCode [trials.myTrialEnd.data]];
    end
    
    if isfield(trials,'trialStart')
        startTime = [startTime [trials.trialStart.timeMS]];
    end
    
    if isfield(trials,'stimulusOn')
        allStimulusIndex = [allStimulusIndex [trials.stimulusOn.data]'];
    end
    
    if isfield(trials,'stimulusOnTime')
        allStimulusOnTimes = [allStimulusOnTimes [trials.stimulusOnTime.timeMS]'];
    end
    
    if isfield(trials,'stimDesc')
        gaborIndex = [gaborIndex [trials.stimDesc.data.gaborIndex]];
        stimType = [stimType [trials.stimDesc.data.stimType]];
        azimuthDeg = [azimuthDeg [trials.stimDesc.data.azimuthDeg]];
        elevationDeg = [elevationDeg [trials.stimDesc.data.elevationDeg]];
        sigmaDeg = [sigmaDeg [trials.stimDesc.data.sigmaDeg]];
        if isfield(trials.stimDesc.data,'radiusDeg')
            radiusExists=1;
            radiusDeg = [radiusDeg [trials.stimDesc.data.radiusDeg]];
        else
            radiusExists=0;
        end
        spatialFreqCPD = [spatialFreqCPD [trials.stimDesc.data.spatialFreqCPD]];
        orientationDeg = [orientationDeg [trials.stimDesc.data.directionDeg]];
        contrastPC = [contrastPC [trials.stimDesc.data.contrastPC]];
        temporalFreqHz = [temporalFreqHz [trials.stimDesc.data.temporalFreqHz]];
    end
end

% Sort stim properties by stimType
numGabors = length(unique(gaborIndex));
for i=1:numGabors
    gaborIndexFromStimulusOn{i} = find(allStimulusIndex==i-1);
    gaborIndexFromStimDesc{i} = find(gaborIndex==i-1);
end

if isequal(gaborIndexFromStimDesc,gaborIndexFromStimulusOn)
    for i=1:numGabors
        LL.(['time' num2str(i-1)]) = allStimulusOnTimes(gaborIndexFromStimulusOn{i});
        LL.(['stimType' num2str(i-1)]) = stimType(gaborIndexFromStimulusOn{i});
        LL.(['azimuthDeg' num2str(i-1)]) = azimuthDeg(gaborIndexFromStimulusOn{i});
        LL.(['elevationDeg' num2str(i-1)]) = elevationDeg(gaborIndexFromStimulusOn{i});
        LL.(['sigmaDeg' num2str(i-1)]) = sigmaDeg(gaborIndexFromStimulusOn{i});
        if radiusExists
            LL.(['radiusDeg' num2str(i-1)]) = radiusDeg(gaborIndexFromStimulusOn{i});
        end
        LL.(['spatialFreqCPD' num2str(i-1)]) = spatialFreqCPD(gaborIndexFromStimulusOn{i});
        LL.(['orientationDeg' num2str(i-1)]) = orientationDeg(gaborIndexFromStimulusOn{i});
        LL.(['contrastPC' num2str(i-1)]) = contrastPC(gaborIndexFromStimulusOn{i});
        LL.(['temporalFreqHz' num2str(i-1)]) = temporalFreqHz(gaborIndexFromStimulusOn{i});
    end
else
    error('Gabor indices from stimuluOn and stimDesc do not match!!');
end

LL.eotCode = eotCode;
LL.myEotCode = myEotCode;
LL.startTime = startTime/1000; % in seconds
LL.endTime = endTime/1000; % in seconds
LL.instructTrial = instructTrial;
LL.catchTrial = catchTrial;
LL.trialCertify = trialCertify;

end