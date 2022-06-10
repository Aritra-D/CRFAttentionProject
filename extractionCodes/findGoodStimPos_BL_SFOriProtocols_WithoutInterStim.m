% find goodStimNums for Baseline for SF-Ori Protocols without interStim
% Period

% load StimResults.mat for the protocol
subjectName = 'NN';
expDate = '120821';
protocolName = 'GRF_004';
gridType = 'EEG';
folderSourceString = 'E:\';
% ignoreTargetStimFlag = 1; % set as 1 in GRF protocols with fixation Mode on

folderExtract = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData');
load(fullfile(folderExtract,'stimResults.mat'));

totalStims = length(stimResults.eotCodes);
disp(['Number of trials: ' num2str(max(stimResults.trialNumber))]);
disp(['Number of stimuli: ' num2str(totalStims)]);

% exclude uncertified trials, catch trials and instruction trials
tc = find(stimResults.trialCertify==1);
it = find(stimResults.instructionTrials==1);
ct = find(stimResults.catch==1);

badStimNums = [it tc]; % catch trials are now considered good

%eottypes
% 0 - correct, 1 - wrong, 2-failed, 3-broke, 4-ignored, 5-False
% Alarm/quit, 6 - distracted, 7 - force quit
%disp('Analysing correct, wrong and failed trials');
%badEOTs = find(stimResults.eotCodes>2); 
%disp('Analysing correct and wrong trials')
%badEOTs = find(stimResults.eotCodes>1); 
disp('Analysing only correct trials')
badEOTs = find(stimResults.eotCodes>0); 
badStimNums = [badStimNums badEOTs];

goodStimNums = setdiff(1:totalStims,unique(badStimNums));

stimPosition_badStimsRemoved = stimResults.stimPosition;
stimPosition_badStimsRemoved(unique(badStimNums))=[];

trialNumber_badStimsRemoved = stimResults.trialNumber;
trialNumber_badStimsRemoved(unique(badStimNums))=[];

firstStim = find(stimPosition_badStimsRemoved ==1);
trialNums = trialNumber_badStimsRemoved(firstStim);

goodBL_stimPos.stimNum = firstStim; goodBL_stimPos.trialNum = trialNums;

