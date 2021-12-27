% This function is used to extract the digital data for the SRC Protocol.
% It is copied from the GRF protocol.

function [goodStimNums,goodStimTimes] = extractDigitalDataSRCLL(folderExtract)

readDigitalCodesSRC(folderExtract); % writes stimResults and trialResults
[goodStimNums,goodStimTimes] = getGoodStimNumsSRC(folderExtract); % Good stimuli
save(fullfile(folderExtract,'goodStimNums.mat'),'goodStimNums','goodStimTimes');
end

function [stimResults,trialResults,trialEvents] = readDigitalCodesSRC(folderExtract)

kForceQuit=7;

% TrialEvents are actually not useful - just keeping for compatibility with
% older programs.

trialEvents{1} = 'TS'; % Trial start
trialEvents{2} = 'TE'; % Trial End

load(fullfile(folderExtract,'digitalEvents.mat'));

allDigitalCodesInDec = [digitalCodeInfo.codeNumber];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the times and values of the events in trialEvents
useSingelITC18Flag=1; useSimpleCodeFlag=1;
for i=1:length(trialEvents)
    pos = find(convertStrCodeToDec(trialEvents{i},useSingelITC18Flag,useSimpleCodeFlag)==allDigitalCodesInDec);
    if isempty(pos)
        disp(['Code ' trialEvents{i} ' not found!!']);
    else
        trialResults(i).times = [digitalCodeInfo(pos).time]; %#ok<*AGROW>
        trialResults(i).value = [digitalCodeInfo(pos).value];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Lablib data structure
load(fullfile(folderExtract,'LL.mat'));

%%%%%%%%%%%%%%%%% Get info from LL to construct stimResults %%%%%%%%%%%%%%%
% Single Entries
stimResults.azimuth0Deg = LL.azimuth0Deg;
stimResults.azimuth1Deg = LL.azimuth1Deg;
stimResults.elevation0Deg = LL.elevation0Deg;
stimResults.elevation1Deg = LL.elevation1Deg;
stimResults.spatialFrequency0 = LL.spatialFreq0CPD;
stimResults.spatialFrequency1 = LL.spatialFreq1CPD;
stimResults.sigma = LL.sigmaDeg;
if isfield(LL,'radiusDeg')
    stimResults.radius = LL.radiusDeg;
end
stimResults.baseOrientation0 = LL.baseOrientation0Deg;
stimResults.baseOrientation1 = LL.baseOrientation1Deg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get timing
trialStartTimes = [digitalCodeInfo(find(convertStrCodeToDec('TS',1,1)==allDigitalCodesInDec)).time];
stimOnsetTimes = [digitalCodeInfo(find(convertStrCodeToDec('ON',1,1)==allDigitalCodesInDec)).time];
trialStartTimesLL = LL.startTime;
stimOnsetTimesLL = LL.stimOnTimes/1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Compare TS data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diffTD = diff(trialStartTimes); diffTL = diff(trialStartTimesLL);
maxDiffMS = 1000*max(abs(diffTD(:) - diffTL(:)));

maxDiffCutoffMS = max(maxDiffMS); % throw an error if the difference exceeds 5 ms
if maxDiffMS > maxDiffCutoffMS
    error(['The digital TrialStartTimes do not match with the LL data... maxDiffMS: ' num2str(maxDiffMS) ' ms']);
else
    disp(['Maximum difference between LL and LFP/EEG start times: ' num2str(maxDiffMS) ' ms']);
    numTrials = length(trialStartTimes);
end

%%%%%%%%%%%%%%%%%%%%%%%%% Compare stim onset data %%%%%%%%%%%%%%%%%%%%%%%%%
if length(stimOnsetTimes) ~= length(stimOnsetTimesLL)
    error('Unequal number of stimulus onset times in LL and digital stream');
else
    diffTD = diff(stimOnsetTimes); diffTL = diff(stimOnsetTimesLL);
    maxDiffMS = 1000*max(abs(diffTD(:) - diffTL(:)));
    
    maxDiffCutoffMS = max(maxDiffMS); % throw an error if the difference exceeds 5 ms
    if maxDiffMS > maxDiffCutoffMS
        error('The digital stimOnsetTimes do not match with the LL data...');
    else
        disp(['Maximum difference between LL and LFP/EEG stimOnset times: ' num2str(maxDiffMS) ' ms']);
    
        stimResults.time = stimOnsetTimes;
        stimResults.type0 = LL.stimType0;
        stimResults.type1 = LL.stimType1;
        stimResults.contrastIndex = LL.contrastIndex;
        stimResults.temporalFreqIndex = LL.temporalFreqIndex;
        stimResults.contrast0PC = LL.contrast0PC;
        stimResults.contrast1PC = LL.contrast1PC;
        stimResults.orientation0Deg = LL.orientation0Deg;
        stimResults.orientation1Deg = LL.orientation1Deg;
        stimResults.temporalFreq0Hz = LL.temporalFreq0Hz;
        stimResults.temporalFreq1Hz = LL.temporalFreq1Hz;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attend Loc
attendLoc = LL.attendLoc;
if length(attendLoc) ~= numTrials 
    error('Number of attendLoc entries different from numTrials');
end

% Instruction trials
instructionTrials = LL.instructTrial;
if length(instructionTrials) ~= numTrials 
    error('Number of instruction trial entries different from numTrials');
end

% Catch trials
catchTrials = LL.catchTrial;
if length(catchTrials) ~= numTrials 
    error('Number of catch trial entries different from numTrials');
end

% TrialCertify & TrialEnd (eotCode)
% These two entries may be repeated twice during force quit
trialCertify = LL.trialCertify;
eotCodes = LL.eotCode;
forceQuits = find(eotCodes==kForceQuit);
numForceQuits = length(forceQuits);

if length(eotCodes)-numForceQuits == numTrials
    disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
        num2str(length(eotCodes)) ', ForceQuits: ' num2str(numForceQuits)]);
    goodEOTPos = find(eotCodes ~=kForceQuit);
    eotCodes = eotCodes(goodEOTPos);
    trialCertify = trialCertify(goodEOTPos);
else
     disp(['numTrials: ' num2str(numTrials) ' numEotCodes: '  ...
        num2str(length(eotCodes)) ', forcequits: ' num2str(numForceQuits)]);
    disp('ForceQuit pressed after trial started'); % TODO - deal with this case
    
    % Decrease numTrials by one
    numTrials = numTrials-1;
    stimResults.aborted = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numStims  = getStimPosPerTrial(trialStartTimes,stimOnsetTimes);

pos=0;
for i=1:numTrials 
    if (numStims(i)>0)
        stimResults.attendLoc(pos+1:pos+numStims(i)) = attendLoc(i);
        stimResults.trialNumber(pos+1:pos+numStims(i)) = i;
        stimResults.stimPosition(pos+1:pos+numStims(i)) = 1:numStims(i);
        stimResults.instructionTrials(pos+1:pos+numStims(i)) = instructionTrials(i);
        stimResults.catch(pos+1:pos+numStims(i)) = catchTrials(i);
        stimResults.eotCodes(pos+1:pos+numStims(i)) = eotCodes(i);
        stimResults.trialCertify(pos+1:pos+numStims(i)) = trialCertify(i);
        pos = pos+numStims(i);
    end
end

% Save in folderExtract
save(fullfile(folderExtract,'stimResults.mat'),'stimResults','newSRCFlag'); %#ok<USENS>
save(fullfile(folderExtract,'trialResults.mat'),'trialEvents','trialResults');

end
function [goodStimNums,goodStimTimes] = getGoodStimNumsSRC(folderExtract)

load(fullfile(folderExtract,'stimResults.mat')); %#ok<*LOAD>
if newSRCFlag
load(fullfile(folderExtract,'LL.mat')); %#ok<*LOAD>
end

totalStims = length(stimResults.eotCodes);
disp(['Number of stimuli: ' num2str(totalStims)]);

% exclude uncertified trials, catch trials and instruction trials
tc = find(stimResults.trialCertify==1);
ct = find(stimResults.catch==1);
it = find(stimResults.instructionTrials==1);
badStimNums = [tc ct it];

%eottypes
% 0 - correct, 1 - wrong, 2-failed, 3-broke, 4-ignored, 5-False
% Alarm/quit, 6 - distracted, 7 - force quit
%disp('Analysing correct, wrong and failed trials');
%badEOTs = find(stimResults.eotCodes>2); 
%disp('Analysing correct and wrong trials')
%badEOTs = find(stimResults.eotCodes>1); 
disp('Analysing only correct trials');
badEOTs = find(stimResults.eotCodes>0); 
badStimNums = [badStimNums badEOTs];

goodStimNumsTMP = setdiff(1:totalStims,unique(badStimNums));

% stim types
% 0 - Null, 1 - valid, 2 - target, 3 - frontpadding, 4 - backpadding
disp('Only taking valid stims and the first frontPadding for the baseline');
type01 = stimResults.type0 .* stimResults.type1;

bothValid = find(type01==1);
allFrontPad = find(type01==9);
firstStim = find(stimResults.stimPosition==1);
firstFrontPad = intersect(allFrontPad,firstStim);

if newSRCFlag ==0
goodStimNums = intersect(goodStimNumsTMP,[bothValid firstFrontPad]);
goodStimTimes = stimResults.time(goodStimNums);
disp(['Number of good stimuli: ' num2str(length(goodStimNums))]);


elseif newSRCFlag == 1
    goodStimNums.stimOnset =  setdiff(intersect(firstFrontPad,find(stimResults.eotCodes==0|stimResults.eotCodes==2)),[tc ct it]);
    goodStimNums.targetOnset = setdiff(intersect(find(type01 ==2),find(stimResults.eotCodes==0|stimResults.eotCodes==2)),tc);

    goodStimTimes.stimOnset = stimResults.time(goodStimNums.stimOnset);
    goodStimTimes.targetOnset = stimResults.time(goodStimNums.targetOnset);
end

end
function [numStim,stimOnPos] = getStimPosPerTrial(trialStartTimes, stimStartTimes)

numTrials = length(trialStartTimes);

stimOnPos = cell(1,numTrials);
numStim   = zeros(1,numTrials);

for i=1:numTrials-1
    stimOnPos{i} = intersect(find(stimStartTimes>=trialStartTimes(i)),find(stimStartTimes<trialStartTimes(i+1)));
    numStim(i) = length(stimOnPos{i});
end
stimOnPos{numTrials} = find(stimStartTimes>=trialStartTimes(numTrials));
numStim(numTrials) = length(stimOnPos{numTrials});
end
