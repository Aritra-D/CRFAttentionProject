% The old saveLLData program contained the following functions from the old format
% 1. saveLLDataSRC and saveLLDataGRF
% 2. getStimResultsLLSRC and getStimResultsLLGRF
% 3. saveEyeAndBehaviorDataSRC and saveEyeAndBehaviorDataGRF
% 4. getEyePositionAndBehavioralDataSRC and getEyePositionAndBehavioralDataGRF

% 5. saveEyeDataInDegSRC, saveEyeDataInDeg (GRF suffix added),
% saveEyeDataStimPosGRF and getEyeDataStimPosGRF

% Now saveLLData only contains the old % 1. saveLLDataSRC and
% saveLLDataGRF, while saveEyePositionAndBehaviorData contains the
% remaining four (2-5 above)

% Removed eyeRangeMS, eyeRangeLongMS and maxStimPos. Those are read from
% the LL file directly.

function saveEyePositionAndBehaviorData_newSRC(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,ignoreTargetStimFlag)

if ~exist('FsEye','var');        FsEye=500;                             end % Eye position sampled at 500 Hz for Lablib-EyeLink Rig provided Eye sampling rate is set at 500 Hz in EyeLink System; 200 Hz for Lablib-IScan Rig.
if ~exist('ignoreTargetStimFlag','var'); ignoreTargetStimFlag = 0; end

folderName    = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);

if strncmpi(protocolName,'SRC',3) % SRC
    
    [allTrials,goodTrials,stimData,eyeData,eyeRangeMS] = getEyePositionAndBehavioralDataSRC(subjectName,expDate,protocolName,folderSourceString,FsEye);
    save(fullfile(folderExtract,'BehaviorData.mat'),'allTrials','goodTrials','stimData');
    save(fullfile(folderExtract,'EyeData.mat'),'eyeData','eyeRangeMS');
    
    saveEyeDataInDegSRC(subjectName,expDate,protocolName,folderSourceString,gridType);
else
    
    [allTrials,goodTrials,stimData,eyeData,eyeRangeMS] = getEyePositionAndBehavioralDataGRF(subjectName,expDate,protocolName,folderSourceString,FsEye,ignoreTargetStimFlag); %#ok<*ASGLU,*NASGU>
    save(fullfile(folderExtract,'BehaviorData.mat'),'allTrials','goodTrials','stimData');
    save(fullfile(folderExtract,'EyeData.mat'),'eyeData','eyeRangeMS');
    
    saveEyeDataInDegGRF(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,ignoreTargetStimFlag);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allTrials,goodTrials,stimData,eyeData,eyeRangeMS] = getEyePositionAndBehavioralDataSRC(subjectName,expDate,protocolName,folderSourceString,Fs) %#ok<*DEFNU>

if ~exist('Fs','var');                   Fs = 500;                      end    % Eye position sampled at 500 Hz for Lablib-EyeLink Rig provided Eye sampling rate is set at 500 Hz in EyeLink System; 200 Hz for Lablib-IScan Rig.

datFileName = fullfile(folderSourceString,'data','rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

% Get Lablib data
header = readLLFile('i',datFileName);
stimLeadDuration = header .stimLeadMS.data;

if isfield(header,'cueDurationMS')
    cueDurationMS    = header.cueDurationMS.data;
    precueDurationMS = header.precueDurationMS.data;
    precueJitterPC   = header.precueJitterPC.data;
else
    cueDurationMS = 0;
    precueDurationMS = 1000;
    precueJitterPC   = 0;
end
minFixationDurationMS = cueDurationMS + round((1-precueJitterPC/100) * precueDurationMS);

minStimDurationMS = round((1-header.stimJitterPC.data/100) * header.stimDurationMS.data);
minInterstimDurationMS = round((1-header.interstimJitterPC.data/100) * header.interstimMS.data);

eyeRangeMS.stim = [-min(minFixationDurationMS,minInterstimDurationMS)+1000/Fs minStimDurationMS-1000/Fs]; % Around each stimulus onset, data should be available for this range. 2 samples are reduced on each range because sometimes there are minor timing shifts and 2 samples may not be collected.
eyeRangeMS.stimOnset = [-minFixationDurationMS+1000/Fs minStimDurationMS*((stimLeadDuration/minStimDurationMS)+1)-1000/Fs];
eyeRangeMS.targetOnset = [-minFixationDurationMS+1000/Fs min(minFixationDurationMS,minInterstimDurationMS)-1000/Fs];

eyeRangePos.stim = eyeRangeMS.stim*Fs/1000;
eyeRangePos.stimOnset = eyeRangeMS.stimOnset*Fs/1000;
eyeRangePos.targetOnset = eyeRangeMS.targetOnset*Fs/1000;

% Stimulus properties
numTrials = header.numberOfTrials;
stimNumber_stimOnset = 1;
stimNumber_TargetOnset = 1;
stimNumber = 1;
correctIndex=1;
trialEndIndex=1;

for i=1:numTrials
    disp(['Behavior: trial ' num2str(i) ' of ' num2str(numTrials)]);
    clear trials
    trials = readLLFile('t',i);
    
    if isfield(trials,'trialEnd')
        allTrials.trialEnded(i) = 1;
        allTrials.catchTrials(trialEndIndex) = trials.trial.data.catchTrial;
        allTrials.instructTrials(trialEndIndex) = trials.trial.data.instructTrial;
        allTrials.trialCertify(trialEndIndex) = trials.trialCertify.data;
        allTrials.targetPosAllTrials(trialEndIndex) = trials.trial.data.targetIndex+1;
        allTrials.eotCodes(trialEndIndex) = trials.trialEnd.data;
        
        allTrials.fixWindowSize(trialEndIndex) = trials.fixWindowData.data.windowDeg.size.width;
        %allTrials.respWindowSize(trialEndIndex) = trials.respWindowData.data.windowDeg.size.width; % instead of responseWindowData
        allTrials.certifiedNonInstruction(trialEndIndex) = (allTrials.instructTrials(trialEndIndex)==0)*(allTrials.trialCertify(trialEndIndex)==0);
        
        if (allTrials.eotCodes(trialEndIndex)==0 || allTrials.eotCodes(trialEndIndex)==2) &&  (allTrials.certifiedNonInstruction(trialEndIndex)==1) ...
                && (allTrials.catchTrials(trialEndIndex)==0) % Work on only Correct and Failed Trials, which are not instruction, catch or uncertified trials
            
            % Get Eye Data
            eyeX = trials.eyeXData.data;
            eyeY = trials.eyeYData.data;
            % eyeStartTime = trials.eyeXData.timeMS(1);  % This is wrong.
            % The eye data is synchronized with trialStartTime.
            
            % Not any more. Now after trialStart, we sleep for sometime to
            % send long digital pulses. Now we use the start of eye
            % calibration as the onset time.
            eyeStartTime = trials.eyeCalibrationData.timeMS; % trials.trialStart.timeMS;
            eyeAllTimes = eyeStartTime + (0:(length(eyeX)-1))*(1000/Fs);
            
            stimOnTimes  = [trials.stimulusOn.timeMS];
            numStimuli = allTrials.targetPosAllTrials(trialEndIndex); %=length(stimOnTimes)/3;
            
            goodTrials.targetPos(correctIndex) = numStimuli;
            goodTrials.targetTime(correctIndex) = stimOnTimes(trials.trial.data.targetIndex+1); % better to use targetIndex instead of using 'end' index. For protocols where stim duration is smaller compared to response time, trial ends with backpadded stimuli.
            goodTrials.fixateMS(correctIndex) = trials.fixate.timeMS;
            goodTrials.fixonMS(correctIndex) = trials.fixOn.timeMS;
            goodTrials.stimOnTimes{correctIndex} = stimOnTimes;
            goodTrials.trialNum(correctIndex) = i;
            
            clear stimType
            stimType = ([trials.stimDesc.data.type0]) .* ([trials.stimDesc.data.type1]);
            goodTrials.stimType{correctIndex} = stimType;
            
            for j=1:numStimuli

                if (stimType(j)==9)&& (j==1) % First Frontpadded Stimulus/ Stim Onset % First stimulus may not have sufficient baseline
                    stimTime = stimOnTimes(j);
                    stp=find(eyeAllTimes>=stimTime, 1 );
                    stimData.stimOnsetTimeFromFixate(stimNumber_stimOnset) = stimTime-trials.fixate.timeMS;
                    stimData.stimPos_stimOnset(stimNumber_stimOnset) = j;
                    stimData.stimType_stimOnset(stimNumber_stimOnset) = stimType(j);
                    
                    if isempty(stp)
                        disp('Eye data entries missing and will be replaced by zeros');
                        eyeData.stimOnset(stimNumber_stimOnset).eyePosDataX = zeros(diff(eyeRangePos.stimOnset),1);
                        eyeData.stimOnset(stimNumber_stimOnset).eyePosDataY = zeros(diff(eyeRangePos.stimOnset),1);
                    else % if starting position is found
                        startingPos = max(1,stp+eyeRangePos.stimOnset(1));
                        if stp+eyeRangePos.stimOnset(2)-1 <= length(eyeX)
                            eyeData.stimOnset(stimNumber_stimOnset).eyePosDataX = eyeX(stp+eyeRangePos.stimOnset(1):stp+eyeRangePos.stimOnset(2)-1); %#ok<*AGROW>
                            eyeData.stimOnset(stimNumber_stimOnset).eyePosDataY = eyeY(stp+eyeRangePos.stimOnset(1):stp+eyeRangePos.stimOnset(2)-1);
                        else % if data entries missing; it is assumed that the eye data is missing from end of datastream
                            numMissingEntries = (stp+eyeRangePos.stimOnset(2)-1) - length(eyeX);
                            disp([num2str(numMissingEntries) ' entries missing and will be replaced by the last value']);
                            eyeData.stimOnset(stimNumber_stimOnset).eyePosDataX = [eyeX(startingPos:end) ; (eyeX(end)+zeros(numMissingEntries,1))]; %#ok<*AGROW>
                            eyeData.stimOnset(stimNumber_stimOnset).eyePosDataY = [eyeY(startingPos:end) ; (eyeY(end)+zeros(numMissingEntries,1))];
                        end
                        eyeData.trialNum_stim(stimNumber_stimOnset) = i;
                    end
                    eyeData.stimOnset(stimNumber_stimOnset).eyeCal = trials.eyeCalibrationData.data.cal;
                    stimNumber_stimOnset = stimNumber_stimOnset+1;
                    
                elseif (stimType(j)==2) % Target
                    stimTime = stimOnTimes(j);
                    stp=find(eyeAllTimes>=stimTime, 1 );
                    stimData.stimPos_targetOnset(stimNumber_TargetOnset) = j;
                    stimData.stimType_targetOnset(stimNumber_TargetOnset) = stimType(j);
                    
                    if isempty(stp)
                        disp('Eye data entries missing and will be replaced by zeros');
                        eyeData.targetOnset(stimNumber_TargetOnset).eyePosDataX = zeros(diff(eyeRangePos.targetOnset),1);
                        eyeData.targetOnset(stimNumber_TargetOnset).eyePosDataY = zeros(diff(eyeRangePos.targetOnset),1);
                    else
                        startingPos = max(1,stp+eyeRangePos.targetOnset(1));
                        if stp+eyeRangePos.targetOnset(2)-1 <= length(eyeX)
                            eyeData.targetOnset(stimNumber_TargetOnset).eyePosDataX = eyeX(stp+eyeRangePos.targetOnset(1):stp+eyeRangePos.targetOnset(2)-1);
                            eyeData.targetOnset(stimNumber_TargetOnset).eyePosDataY = eyeY(stp+eyeRangePos.targetOnset(1):stp+eyeRangePos.targetOnset(2)-1);
                        else
                            numMissingEntries = (stp+eyeRangePos.targetOnset(2)-1) - length(eyeX);
                            disp([num2str(numMissingEntries) ' entries missing and will be replaced by the last value']);
                            eyeData.stimOnset(stimNumber_TargetOnset).eyePosDataX = [eyeX(startingPos:end) ; (eyeX(end)+zeros(numMissingEntries,1))]; %#ok<*AGROW>
                            eyeData.stimOnset(stimNumber_TargetOnset).eyePosDataY = [eyeY(startingPos:end) ; (eyeY(end)+zeros(numMissingEntries,1))];
                        end
                        eyeData.trialNum_target(stimNumber_TargetOnset) = i;
                    end
                    eyeData.targetOnset(stimNumber_TargetOnset).eyeCal = trials.eyeCalibrationData.data.cal;
                    stimNumber_TargetOnset = stimNumber_TargetOnset+1;

                elseif (stimType(j)==9) ||(stimType(j)==1) % Frontpad or Valid % stimBased processing of eye data for SRC-Short Protocols

                    stimTime = stimOnTimes(j);
                    stp=find(eyeAllTimes>=stimTime, 1 );
                    
                    stimData.stimOnsetTimeFromFixate(stimNumber) = stimTime-trials.fixate.timeMS;
                    stimData.stimPos(stimNumber) = j;
                    stimData.stimType(stimNumber) = stimType(j);
                    
% %                     if (stimType(j)==9) % First stimulus may not have sufficient baseline
%                         if isempty(stp)
%                             disp('Eye data entries missing and will be replaced by zeros');
%                             eyeData.stim(stimNumber).eyePosDataX = zeros(diff(eyeRangePos.stim),1);
%                             eyeData.stim(stimNumber).eyePosDataY = zeros(diff(eyeRangePos.stim),1);
%                         else
%                             startingPos = max(1,stp+eyeRangePos.stim(1));
%                             if stp+eyeRangePos.stim(2)-1 <= length(eyeX)
%                                 endingPos = stp+eyeRangePos.stim(2)-1;
%                                 eyeData.stim(stimNumber).eyePosDataX = eyeX(stp:endingPos); %#ok<*AGROW>
%                                 eyeData.stim(stimNumber).eyePosDataY = eyeY(stp:endingPos);
%                             else
%                                 numMissingEntries = (stp+eyeRangePos.stim(2)-1) - length(eyeX);
%                                 disp([num2str(numMissingEntries) ' entries missing and will be replaced by the last value']);
%                                 eyeData.stim(stimNumber).eyePosDataX = [eyeX(stp:end) ; (eyeX(end)+zeros(numMissingEntries,1))]; %#ok<*AGROW>
%                                 eyeData.stim(stimNumber).eyePosDataY = [eyeY(stp:end) ; (eyeY(end)+zeros(numMissingEntries,1))];
%                             end
%                         end
%                         eyeData.stim(stimNumber).eyeCal = trials.eyeCalibrationData.data.cal;
%                         stimNumber=stimNumber+1;
%                     elseif (stimType(j)==1)
                        if isempty(stp)
                            disp('Eye data entries missing and will be replaced by zeros');
                            eyeData.stim(stimNumber).eyePosDataX = zeros(diff(eyeRangePos.stim),1);
                            eyeData.stim(stimNumber).eyePosDataY = zeros(diff(eyeRangePos.stim),1);
                        else
                            startingPos = max(1,stp+eyeRangePos.stim(1));
                            if stp+eyeRangePos.stim(2)-1 <= length(eyeX)
                                endingPos = stp+eyeRangePos.stim(2)-1;
                                eyeData.stim(stimNumber).eyePosDataX = eyeX(startingPos:endingPos);
                                eyeData.stim(stimNumber).eyePosDataY = eyeY(startingPos:endingPos);
                            else
                                numMissingEntries = (stp+eyeRangePos.stim(2)-1) - length(eyeX);
                                disp([num2str(numMissingEntries) ' entries missing and will be replaced by the last value']);
                                eyeData.stim(stimNumber).eyePosDataX = [eyeX(startingPos:end) ; (eyeX(end)+zeros(numMissingEntries,1))];
                                eyeData.stim(stimNumber).eyePosDataY = [eyeX(startingPos:end) ; (eyeY(end)+zeros(numMissingEntries,1))];
                            end
                        end
                        eyeData.stim(stimNumber).eyeCal = trials.eyeCalibrationData.data.cal;
                        stimNumber=stimNumber+1;
%                     end
                end
            end
            correctIndex=correctIndex+1;
        end
        trialEndIndex=trialEndIndex+1;
    end
end
end
function [allTrials,goodTrials,stimData,eyeData,eyeRangeMS] = getEyePositionAndBehavioralDataGRF(subjectName,expDate,protocolName,folderSourceString,Fs,fixationMode)

if ~exist('Fs','var');                  Fs = 200;                       end    % Eye position sampled at 200 Hz.
if ~exist('fixationMode','var'); fixationMode = 0; end

datFileName = fullfile(folderSourceString,'data','rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

% Get Lablib data
header = readLLFile('i',datFileName);

minFixationDurationMS = round((1-header.behaviorSetting.data.fixateJitterPC/100) * header.behaviorSetting.data.fixateMS);
stimDurationMS = header.mapStimDurationMS.data;
interStimDurationMS = header.mapInterstimDurationMS.data;

eyeRangeMS = [-min(minFixationDurationMS,interStimDurationMS)+1000/Fs stimDurationMS-1000/Fs]; % Around each stimulus onset, data should be available for this range. 2 samples are reduced on each range because sometimes there are minor timing shifts and 2 samples may not be collected.
eyeRangePos = eyeRangeMS*Fs/1000;

% Stimulus properties
numTrials = header.numberOfTrials;
stimNumber=1;
correctIndex=1;
trialEndIndex=1;

for i=1:numTrials
    disp(['Behavior: trial ' num2str(i) ' of ' num2str(numTrials)]);
    clear trials
    trials = readLLFile('t',i);
    
    if isfield(trials,'trialEnd')
        allTrials.trialEnded(i) = 1;
        allTrials.catchTrials(trialEndIndex) = trials.trial.data.catchTrial;
        allTrials.instructTrials(trialEndIndex) = trials.trial.data.instructTrial;
        allTrials.trialCertify(trialEndIndex) = trials.trialCertify.data;
        allTrials.targetPosAllTrials(trialEndIndex) = trials.trial.data.targetIndex+1;
        allTrials.eotCodes(trialEndIndex) = trials.trialEnd.data;
        
        allTrials.fixWindowSize(trialEndIndex) = trials.fixWindowData.data.windowDeg.size.width;
        allTrials.respWindowSize(trialEndIndex) = trials.responseWindowData.data.windowDeg.size.width;
        allTrials.certifiedNonInstruction(trialEndIndex) = (allTrials.instructTrials(trialEndIndex)==0)*(allTrials.trialCertify(trialEndIndex)==0);
        
        if (allTrials.eotCodes(trialEndIndex)==0) &&  (allTrials.certifiedNonInstruction(trialEndIndex)==1)
            %&& (allTrials.catchTrials(trialEndIndex)==0) % Work on only Correct Trials, which are not instruction or uncertified trials. Include catch trials
            
            % In fixation mode, all trials are catch trials, irrespective
            % of what the Lablib trial says. This is to work around a bug
            % in the GaborRFMap UI where Catch Trials is not 100% even when
            % run in fixation mode.
            if fixationMode
                isCatchTrial = 1;
            else
                isCatchTrial = (allTrials.catchTrials(trialEndIndex)==1);
            end
            
            % Get Eye Data
            if isfield(trials,'eyeXData')
                eyeX = trials.eyeXData.data;
                eyeY = trials.eyeYData.data;
            elseif isfield(trials,'eyeRXData')
                eyeX = trials.eyeRXData.data;
                eyeY = trials.eyeRYData.data;
            elseif isfield(trials,'eyeLXData')
                eyeX = trials.eyeLXData.data;
                eyeY = trials.eyeLYData.data;
            end
            
            % eyeStartTime = trials.eyeXData.timeMS(1);  % This is wrong.
            % The eye data is synchronized with trialStartTime.
            % eyeStartTime = trials.trialStart.timeMS;
            
            % Not any more. Now after trialStart, we sleep for sometime to
            % send long digital pulses. Now we use the start of eye
            % calibration as the onset time.
            eyeStartTime = trials.eyeLeftCalibrationData.timeMS;
            eyeAllTimes = eyeStartTime + (0:(length(eyeX)-1))*(1000/Fs);
            
            stimOnTimes  = [trials.stimulusOnTime.timeMS];
            numStimuli = length(stimOnTimes)/3; % = allTrials.targetPosAllTrials(trialEndIndex); %=length(stimOnTimes)/3;
            
            goodTrials.targetPos(correctIndex) = numStimuli;
            goodTrials.targetTime(correctIndex) = stimOnTimes(end);
            goodTrials.fixateMS(correctIndex) = trials.fixate.timeMS;
            goodTrials.fixonMS(correctIndex) = trials.fixOn.timeMS;
            goodTrials.stimOnTimes{correctIndex} = stimOnTimes;
            
            % Find position of Gabor1
            gaborPos = find([trials.stimDesc.data.gaborIndex]==1); % could be 4 gabors for GRF protocol
            
            if isCatchTrial
                stimEndIndex = numStimuli;    % Take the last stimulus because it is still a valid stimulus
            else
                stimEndIndex = numStimuli-1;  % Don't take the last one because it is the target
            end
            
            if stimEndIndex>0  % At least one stimulus
                for j=1:stimEndIndex
                    stimTime = stimOnTimes(gaborPos(j));
                    stp=find(eyeAllTimes>=stimTime,1);
                    
                    stimData.stimOnsetTimeFromFixate(stimNumber) = stimTime-trials.fixate.timeMS;
                    stimData.stimPos(stimNumber) = j;
                    
                    if isempty(stp)
                        disp('Eye data entries missing and will be replaced by zeros');
                        eyeData(stimNumber).eyePosDataX = zeros(diff(eyeRangePos),1);
                        eyeData(stimNumber).eyePosDataY = zeros(diff(eyeRangePos),1);
                    else
                        startingPos = max(1,stp+eyeRangePos(1));
                        if stp+eyeRangePos(2)-1 <= length(eyeX)
                            endingPos = stp+eyeRangePos(2)-1;
                            eyeData(stimNumber).eyePosDataX = eyeX(startingPos:endingPos);
                            eyeData(stimNumber).eyePosDataY = eyeY(startingPos:endingPos);
                        else
                            numMissingEntries = (stp+eyeRangePos(2)-1) - length(eyeX);
                            disp([num2str(numMissingEntries) ' entries missing and will be replaced by the last value']);
                            eyeData(stimNumber).eyePosDataX = [eyeX(startingPos:end) ; (eyeX(end)+zeros(numMissingEntries,1))];
                            eyeData(stimNumber).eyePosDataY = [eyeY(startingPos:end) ; (eyeY(end)+zeros(numMissingEntries,1))];
                        end
                    end
                    
                    if isfield(trials,'eyeXData')
                        eyeData(stimNumber).eyeCal = trials.eyeCalibrationData.data.cal;
                    elseif isfield(trials,'eyeRXData')
                        eyeData(stimNumber).eyeCal = trials.eyeRightCalibrationData.data.cal;
                    elseif isfield(trials,'eyeLXData')
                        eyeData(stimNumber).eyeCal = trials.eyeLeftCalibrationData.data.cal;
                    end
                    
                    stimNumber=stimNumber+1;
                end
            end
            correctIndex=correctIndex+1;
        end
        trialEndIndex=trialEndIndex+1;
    end
end
end
% Additional analysis
function saveEyeDataInDegSRC(subjectName,expDate,protocolName,folderSourceString,gridType)
% The difference between saveEyeDataInDeg and saveEyeDataInDegSRC is that
% the frontPad stimuli are also saved in SRC.

folderName    = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
folderExtract = fullfile(folderName,'extractedData');

clear eyeData
load(fullfile(folderExtract,'EyeData.mat')); %#ok<*LOAD>

[eyeDataDegX_stimOnset,eyeDataDegY_stimOnset] = convertEyeDataToDeg(eyeData.stimOnset,0);
[eyeDataDegX_targetOnset,eyeDataDegY_targetOnset] = convertEyeDataToDeg(eyeData.targetOnset,0);
[eyeDataDegX_stim,eyeDataDegY_stim] = convertEyeDataToDeg(eyeData.stim,0);

eyeDataDegX.stimOnset = eyeDataDegX_stimOnset;
eyeDataDegX.targetOnset = eyeDataDegX_targetOnset;
eyeDataDegX.stim = eyeDataDegX_stim;

eyeDataDegY.stimOnset = eyeDataDegY_stimOnset;
eyeDataDegY.targetOnset = eyeDataDegY_targetOnset;
eyeDataDegY.stim = eyeDataDegY_stim;


% if length(eyeDataDegX_stimOnset) == length(eyeDataDegX_targetOnset) && length(eyeDataDegY_stimOnset) == length(eyeDataDegY_targetOnset)
%     for i=1:length(eyeDataDegX_stimOnset)
%         lengthEyeSignal_stimOnset = size(eyeDataDegX_stimOnset,2);
%         lengthEyeSignal_targetOnset = size(eyeDataDegX_targetOnset{i},1);
%
%         eyeSpeedX.stimOnset{i} = [eyeDataDegX_stimOnset{i}(2:lengthEyeSignal_stimOnset)-eyeDataDegX_stimOnset{i}(1:lengthEyeSignal_stimOnset-1);0];
%         eyeSpeedY.stimOnset{i} = [eyeDataDegY_stimOnset{i}(2:lengthEyeSignal_stimOnset)-eyeDataDegY_stimOnset{i}(1:lengthEyeSignal_stimOnset-1);0];
%         eyeSpeedX.targetOnset{i} = [eyeDataDegX_targetOnset{i}(2:lengthEyeSignal_targetOnset)-eyeDataDegX_targetOnset{i}(1:lengthEyeSignal_targetOnset-1);0];
%         eyeSpeedY.targetOnset{i} = [eyeDataDegY_targetOnset{i}(2:lengthEyeSignal_targetOnset)-eyeDataDegY_targetOnset{i}(1:lengthEyeSignal_targetOnset-1);0];
%     end
% else
%     error('stimOnset and targetOnset trial length are not equal!')
% end
%
% for i=1:length(eyeDataDegX_stim)
%     lengthEyeSignal_stim = size(eyeDataDegX_stim{i},1);
%
%     eyeSpeedX.stim{i} = [eyeDataDegX_stim{i}(2:lengthEyeSignal_stim)-eyeDataDegX_stim{i}(1:lengthEyeSignal_stim-1);0];
%     eyeSpeedY.stim{i} = [eyeDataDegY_stim{i}(2:lengthEyeSignal_stim)-eyeDataDegY_stim{i}(1:lengthEyeSignal_stim-1);0];
% end


folderSave = fullfile(folderName,'segmentedData','eyeData');
makeDirectory(folderSave);
save(fullfile(folderSave,'eyeDataDeg.mat'),'eyeDataDegX','eyeDataDegY');
% save(fullfile(folderSave,'eyeSpeed.mat'),'eyeSpeedX','eyeSpeedY');

end
function saveEyeDataInDegGRF(subjectName,expDate,protocolName,folderSourceString,gridType,FsEye,fixationMode)

folderName    = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
folderExtract = fullfile(folderName,'extractedData');

clear eyeData
load(fullfile(folderExtract,'EyeData.mat'));

clear goodStimNums
load(fullfile(folderExtract,'goodStimNums.mat'));

if exist(fullfile(folderExtract,'validStimAfterTarget.mat'),'file')
    load(fullfile(folderExtract,'validStimAfterTarget.mat'));
    disp(['Removing ' num2str(length(validStimuliAfterTarget)) ' stimuli from goodStimNums']);
    goodStimNums(validStimuliAfterTarget)=[];
end

clear stimResults
load(fullfile(folderExtract,'stimResults.mat'));

goodStimPos = stimResults.stimPosition(goodStimNums);

% all stimPostions greater than 1
% useTheseStims = find(goodStimPos>1);
useTheseStims = find(goodStimPos>0); % Use all stimPositions, including 1

[eyeDataDegX,eyeDataDegY] = convertEyeDataToDeg(eyeData(useTheseStims),0);
folderSave = fullfile(folderName,'segmentedData','eyeData');
makeDirectory(folderSave);
save(fullfile(folderSave,'eyeDataDeg.mat'),'eyeDataDegX','eyeDataDegY');

% lengthEyeSignal = size(eyeDataDegX,2);
% eyeSpeedX = [eyeDataDegX(:,2:lengthEyeSignal)-eyeDataDegX(:,1:lengthEyeSignal-1) zeros(size(eyeDataDegX,1),1)];
% eyeSpeedY = [eyeDataDegY(:,2:lengthEyeSignal)-eyeDataDegY(:,1:lengthEyeSignal-1) zeros(size(eyeDataDegY,1),1)];
% save([folderSave 'eyeSpeed.mat'],'eyeSpeedX','eyeSpeedY');

% More data saved for GRF protocol
[eyeXAllPos,eyeYAllPos,xs,durationsMS] = getEyeDataStimPosGRF(subjectName,expDate,protocolName,folderSourceString,FsEye,fixationMode);
save(fullfile(folderSave,'EyeDataStimPos.mat'),'eyeXAllPos','eyeYAllPos','xs','durationsMS');
end
function [eyeXAllPos,eyeYAllPos,xs,durationsMS] = getEyeDataStimPosGRF(subjectName,expDate,protocolName,folderSourceString,FsEye,fixationMode)

intervalTimeMS=1000/FsEye;
datFileName = fullfile(folderSourceString,'data','rawData',subjectName,[subjectName expDate],[subjectName expDate protocolName '.dat']);

if ~exist(datFileName,'file')
    datFileName = fullfile(folderSourceString,'rawData',[subjectName expDate],[subjectName expDate protocolName '.dat']);
end

% Get Lablib data
header = readLLFile('i',datFileName);

minFixationDurationMS = round((1-header.behaviorSetting.data.fixateJitterPC/100) * header.behaviorSetting.data.fixateMS);
stimDurationMS = header.mapStimDurationMS.data;
interStimDurationMS = header.mapInterstimDurationMS.data;
responseTimeMS = header.responseTimeMS.data;
maxStimPos = ceil(ceil(header.maxTargetTimeMS.data + responseTimeMS)/(stimDurationMS+interStimDurationMS) +1);

durationsMS.minFixationDurationMS = minFixationDurationMS;
durationsMS.interStimDurationMS = interStimDurationMS;
durationsMS.stimDurationMS = stimDurationMS;

for j=1:maxStimPos
    eyeXAllPos{j}=[];
    eyeYAllPos{j}=[];
    xs{j}=[];
end

numTrials = header.numberOfTrials;

for i=1:numTrials
    trial = readLLFile('t',i);
    disp(['Extended EyeData: trial ' num2str(i) ' of ' num2str(numTrials)]);
    % Work on only Correct Trials, which are not instruction or uncertified
    % trials. Include catch trials
    if (trial.trialEnd.data == 0) && (trial.trial.data.instructTrial==0) && ...
            (trial.trialCertify.data==0) %&& (trial.trial.data.catchTrial==0)
        
        % In fixation mode, all trials are catch trials, irrespective
        % of what the Lablib trial says. This is to work around a bug
        % in the GaborRFMap UI where Catch Trials is not 100% even when
        % run in fixation mode.
        if fixationMode
            isCatchTrial = 1;
        else
            isCatchTrial = (trial.trial.data.catchTrial==1);
        end
        
        % get eye data
        clear eX eY cal
        if isfield(trial,'eyeXData')
            eX = trial.eyeXData.data';
            eY = trial.eyeYData.data';
            cal=trial.eyeCalibrationData.data.cal;
            timeStartMS = trial.eyeCalibrationData.timeMS;
        elseif isfield(trial,'eyeRXData')
            eX = trial.eyeRXData.data';
            eY = trial.eyeRYData.data';
            cal=trial.eyeRightCalibrationData.data.cal;
            timeStartMS = trial.eyeRightCalibrationData.timeMS;
        elseif isfield(trial,'eyeLXData')
            eX = trial.eyeLXData.data';
            eY = trial.eyeLYData.data';
            cal=trial.eyeLeftCalibrationData.data.cal;
            timeStartMS = trial.eyeLeftCalibrationData.timeMS;
        end
        
        if isCatchTrial
            numUsefulStim = min(trial.trial.data.numStim,maxStimPos); % these are the useful stimuli, including target.
        else
            numUsefulStim = min(trial.trial.data.targetIndex,maxStimPos); % these are the useful stimuli, excluding target.
        end
        
        stimOnTimes = trial.stimulusOnTime.timeMS;
        gaborPos = find([trial.stimDesc.data.gaborIndex]==1);
        
        if numUsefulStim>0
            for j=1:numUsefulStim
                stimOnsetPos = ceil((stimOnTimes(gaborPos(j)) - timeStartMS)/intervalTimeMS);
                
                stp = -(minFixationDurationMS + (j-1)*(stimDurationMS+interStimDurationMS))/intervalTimeMS + 1;
                edp = stimDurationMS/intervalTimeMS - 1;
                list = stp:edp;
                
                if (stimOnsetPos+edp) <= length(eX)
                    eXshort = eX(stimOnsetPos+list);
                    eYshort = eY(stimOnsetPos+list);
                else
                    numMissingEntries = (stimOnsetPos+edp) - length(eX);
                    disp([num2str(numMissingEntries) ' entries missing and will be replaced by the last value']);
                    eXshort = [eX((stimOnsetPos+list(1)):end) (eX(end)+zeros(1,numMissingEntries))];
                    eYshort = [eY((stimOnsetPos+list(1)):end) (eY(end)+zeros(1,numMissingEntries))];
                end
                
                eXshortDeg = cal.m11*eXshort + cal.m21 * eYshort + cal.tX;
                eYshortDeg = cal.m12*eXshort + cal.m22 * eYshort + cal.tY;
                
                eyeXAllPos{j} = cat(1,eyeXAllPos{j},eXshortDeg);
                eyeYAllPos{j} = cat(1,eyeYAllPos{j},eYshortDeg);
                
                if isempty(xs{j})
                    xs{j} = list*intervalTimeMS + (j-1)*(stimDurationMS+interStimDurationMS);
                end
            end
        end
    end
end
end