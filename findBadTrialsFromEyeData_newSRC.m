% Written by Murty Dinavahi; modified by Aritra Das for new SRC
% protocol for EEG studies

function badEyeTrials = findBadTrialsFromEyeData_newSRC(eyeDataDeg,eyeRangeMS,FsEye,checkPeriod,fixationWindowWidth)

if ~exist('fixationWindowWidth','var');         fixationWindowWidth = 4;           end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(eyeDataDeg.eyeDataDegX,'stimOnset') && isfield(eyeDataDeg.eyeDataDegX,'targetOnset') && isfield(eyeDataDeg.eyeDataDegY,'stimOnset') && isfield(eyeDataDeg.eyeDataDegY,'targetOnset')
    eyeDataType_length = 2;
end

badEyeTrials = [];

for i = 1: eyeDataType_length
    if i==1 % StimOnset
        eyeDataDegX = eyeDataDeg.eyeDataDegX.stimOnset;
        eyeDataDegY = eyeDataDeg.eyeDataDegY.stimOnset;
        timeValsEyePos = (eyeRangeMS.stimOnset(1):1000/FsEye:eyeRangeMS.stimOnset(2)-1000/FsEye)/1000;
        if ~exist('checkPeriod','var');             checkPeriod = eyeRangeMS.stimOnset/1000;      end
        timeValsEyeCheckPos = timeValsEyePos>=checkPeriod(1) & timeValsEyePos<=checkPeriod(2);
        
    elseif i==2 % targetOnset
        eyeDataDegX = eyeDataDeg.eyeDataDegX.targetOnset;
        eyeDataDegY = eyeDataDeg.eyeDataDegY.targetOnset;
        timeValsEyePos = (eyeRangeMS.targetOnset(1):1000/FsEye:eyeRangeMS.targetOnset(2)-1000/FsEye)/1000;
        checkPeriod = eyeRangeMS.targetOnset/1000;      
        timeValsEyeCheckPos = timeValsEyePos>=checkPeriod(1) & timeValsEyePos<=checkPeriod(2);
    else
    end
    
    % do baseline correction
    eyeDataDegX = eyeDataDegX - repmat(mean(eyeDataDegX(:,timeValsEyeCheckPos),2),1,size(eyeDataDegX,2));
    eyeDataDegY = eyeDataDegY - repmat(mean(eyeDataDegY(:,timeValsEyeCheckPos),2),1,size(eyeDataDegY,2));
    
    % Find bad trials
    clear xTrialsBeyondFixWindow yTrialsBeyondFixWindow xTrialsNoSignals yTrialsNoSignals badEyeTrialsTMP
    xTrialsBeyondFixWindow = sum(abs(eyeDataDegX(:,timeValsEyeCheckPos))>(fixationWindowWidth/2),2);
    yTrialsBeyondFixWindow = sum(abs(eyeDataDegY(:,timeValsEyeCheckPos))>(fixationWindowWidth/2),2);
    xTrialsNoSignals = sum(abs(eyeDataDegX(:,timeValsEyeCheckPos)),2);
    yTrialsNoSignals = sum(abs(eyeDataDegY(:,timeValsEyeCheckPos)),2);
    
    badEyeTrialsTMP = find(xTrialsBeyondFixWindow>0 | yTrialsBeyondFixWindow>0 | xTrialsNoSignals==0 | yTrialsNoSignals==0);
    if badEyeTrialsTMP==0; badEyeTrialsTMP=[]; end
    
    badEyeTrials = cat(1,badEyeTrials,badEyeTrialsTMP);
    badEyeTrials = unique(badEyeTrials);
end


end
