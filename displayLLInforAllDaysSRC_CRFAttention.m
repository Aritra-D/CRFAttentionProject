% This program is adapted from displayLLInforAllDaysSRC. This has been
% modified for the CRFAttention project.

function displayLLInforAllDaysSRC_CRFAttention(subjectName,expDates,protocolNames,folderSourceString,gridType,removeBreaks,removeIgnores,convertOriValsInLogScale)

if ~exist('removeBreaks','var');            removeBreaks=0;             end
if ~exist('removeIgnores','var');           removeIgnores=0;            end
if ~exist('convertOriValsInLogScale','var');           convertOriValsInLogScale=0;            end

close all;
if ~iscell(expDates)
    [expDates,protocolNames] = convertToCell(expDates,protocolNames);
end

fileStr = getFileStr(subjectName,expDates,protocolNames,folderSourceString,gridType);

hFig = figure(1);
set(hFig,'units','normalized','outerposition',[0 0 1 1])

% Choose day
dayString = getDayString(subjectName,expDates,protocolNames);
hChooseDay = uicontrol('Unit','Normalized','Position',[0.85 0.9 0.1 0.1],...
    'Style','popup','String',dayString,'Callback',{@plotData_callBack});

% choose whether to use or ignore breaks and ignores
hBreaks = uicontrol('Unit','Normalized','Position',[0.75 0.95 0.1 0.05],...
    'Style','checkbox','String','remove Breaks','Callback',{@plotDataLLBar_callBack});
hIgnores = uicontrol('Unit','Normalized','Position',[0.65 0.95 0.1 0.05],...
    'Style','checkbox','String','remove Ignores','Callback',{@plotDataLLBar_callBack});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot LLBars of all days
LLBarGrid = [0.05 0.65 0.65 0.225]; 
numDays = length(expDates);
dX = min(0.035,LLBarGrid(3)/(numDays+2));

% MakeTable

tableLabelGrid = [0 0.45 LLBarGrid(1) 0.2];
tableLabels{1,1} = 'Date';
tableLabels{2,1} = 'Azimuth';
tableLabels{3,1} = 'Elevation';
tableLabels{4,1} = 'Orientation';
tableLabels{5,1} = 'Spatial F';
tableLabels{6,1} = 'Sigma/Radius';
tableLabels{7,1} = 'Day Num';
makeTable(tableLabelGrid,tableLabels);

tableGrid = [LLBarGrid(1) 0.45 numDays*dX 0.2];
 
tableEntries = cell(7,numDays);
for i=1:numDays
    tableEntries{1,i} = [expDates{i}(1:2) '/' expDates{i}(3:4)];
    tableEntries{2,i} = [num2str(fileStr(i).azimuth0Deg) '/' num2str(fileStr(i).azimuth1Deg)];
    tableEntries{3,i} = [num2str(fileStr(i).elevation0Deg) '/' num2str(fileStr(i).elevation1Deg)];
    tableEntries{4,i} = [num2str(fileStr(i).orientation0Deg) '/' num2str(fileStr(i).orientation1Deg)];
    tableEntries{5,i} = [num2str(fileStr(i).spatialFreq0CPD) '/' num2str(fileStr(i).spatialFreq1CPD)];
    tableEntries{6,i} = [num2str(fileStr(i).sigmaDeg) '/' num2str(fileStr(i).radiusDeg)];
    tableEntries{7,i} = num2str(i);
end
makeTable(tableGrid,tableEntries);

%%% Plotting with default values of removeBreaks and removeIgnores
for i=1:numDays
    gridPositionLLBar = [LLBarGrid(1)+(i-1)*dX LLBarGrid(2) dX LLBarGrid(4)];
    displayLLbarSRC(subjectName,expDates{i},protocolNames{i},folderSourceString,gridType,gridPositionLLBar,removeBreaks,removeIgnores);
end

gridPositionLLBar = [LLBarGrid(1)+(numDays+1)*dX LLBarGrid(2) dX LLBarGrid(4)];
displayLLbarSRC(subjectName,expDates,protocolNames,folderSourceString,gridType,gridPositionLLBar,removeBreaks,removeIgnores);


% Plot performance as a function of target Position
gridPositionPerformanceVsTargetPos = [0.05 0.05 0.2 0.175];
gridPositionPercentTargets         = [0.05 0.25 0.2 0.125];
gridPositionCorrect{1}             = [0.3 0.25 0.15 0.125]; % For target position
gridPositionCorrect{2}             = [0.3 0.05 0.15 0.15]; % For target position

displayTargetInfo(gridPositionPerformanceVsTargetPos,gridPositionPercentTargets,gridPositionCorrect,...
    subjectName,expDates,protocolNames,folderSourceString,gridType,removeBreaks,removeIgnores);

% Fixation window histogram
% allFixationData=[];
% for i=1:numDays
%     folderNameTmp = fullfile(folderSourceString,'data',subjectName,gridType,expDates{i},protocolNames{i});
%     [~,fixWindowSizeAllTrials] = getFixationWindowData(folderNameTmp);
%     allFixationData=cat(2,allFixationData,fixWindowSizeAllTrials);
% end

% gridPositionFixationHistogram = [0.5 0.05 0.2 0.15];
% hFixationHist = subplot('Position',gridPositionFixationHistogram);
% plotHistogram(hFixationHist,allFixationData/2,'Fixation Window (Deg)');

gridPositionTemporalInfo = [0.75 0.8 0.2 0.15];
gridPositionTargetInfo = [0.75 0.6 0.2 0.125];
gridPositionPsy = [0.75 0.225 0.2 0.2];
gridPositionReactTimes = [0.75 0.05 0.2 0.15];

    function plotDataLLBar_callBack(~,~)
        
        removeBreaks = get(hBreaks,'val');
        removeIgnores = get(hIgnores,'val');
        
        for ii=1:numDays
            gridPositionLLBar = [LLBarGrid(1)+(ii-1)*dX LLBarGrid(2) dX LLBarGrid(4)];
            displayLLbarSRC(subjectName,expDates{ii},protocolNames{ii},folderSourceString,gridType,gridPositionLLBar,removeBreaks,removeIgnores);
        end

        gridPositionLLBar = [LLBarGrid(1)+(numDays+1)*dX LLBarGrid(2) dX LLBarGrid(4)];
        displayLLbarSRC(subjectName,expDates,protocolNames,folderSourceString,gridType,gridPositionLLBar,removeBreaks,removeIgnores);
        
        num = get(hChooseDay,'val');
        
        if num<=numDays
            %histContrast = fileStr(num).contrastPC0;
            displayTargetInfo(gridPositionPerformanceVsTargetPos,gridPositionPercentTargets,gridPositionCorrect,...
            subjectName,expDates{num},protocolNames{num},folderSourceString,gridType,removeBreaks,removeIgnores);
            [~,fixationData] = getFixationWindowData(fullfile(folderSourceString,'data',subjectName,gridType,expDates{num},protocolNames{num}));
            
            displayLLInfoSRCPsyAndReactInfo(subjectName,expDates{num},protocolNames{num},folderSourceString,gridType, ...
            gridPositionTemporalInfo,gridPositionTargetInfo,gridPositionPsy,gridPositionReactTimes,convertOriValsInLogScale,hFig);
        else
            %histContrast = allContrasts;
            displayTargetInfo(gridPositionPerformanceVsTargetPos,gridPositionPercentTargets,gridPositionCorrect,...
            subjectName,expDates,protocolNames,folderSourceString,gridType,removeBreaks,removeIgnores);
            fixationData = allFixationData;
            
            displayLLInfoSRCPsyAndReactInfo(subjectName,expDates,protocolNames,folderSourceString,gridType, ...
            gridPositionTemporalInfo,gridPositionTargetInfo,gridPositionPsy,gridPositionReactTimes,convertOriValsInLogScale,hFig);
        end
        %plotHistogram(hContrastHist,histContrast,'Contrast (%)');
%         plotHistogram(hFixationHist,fixationData/2,'Fixation Window (Deg)');
    end
    function plotData_callBack(~,~)

        num = get(hChooseDay,'val');
        
        if num<=numDays
            %histContrast = fileStr(num).contrastPC0;
            displayTargetInfo(gridPositionPerformanceVsTargetPos,gridPositionPercentTargets,gridPositionCorrect,...
            subjectName,expDates{num},protocolNames{num},folderSourceString,gridType,removeBreaks,removeIgnores);
%             [~,fixationData] = getFixationWindowData(fullfile(folderSourceString,'data',subjectName,gridType,expDates{num},protocolNames{num}));
            
            displayLLInfoSRCPsyAndReactInfo(subjectName,expDates{num},protocolNames{num},folderSourceString,gridType, ...
            gridPositionTemporalInfo,gridPositionTargetInfo,gridPositionPsy,gridPositionReactTimes,convertOriValsInLogScale,hFig);
        else
            %histContrast = allContrasts;
            displayTargetInfo(gridPositionPerformanceVsTargetPos,gridPositionPercentTargets,gridPositionCorrect,...
            subjectName,expDates,protocolNames,folderSourceString,gridType,removeBreaks,removeIgnores);
%             fixationData = allFixationData;
            
            displayLLInfoSRCPsyAndReactInfo(subjectName,expDates,protocolNames,folderSourceString,gridType,...
            gridPositionTemporalInfo,gridPositionTargetInfo,gridPositionPsy,gridPositionReactTimes,convertOriValsInLogScale,hFig);
        end
        %plotHistogram(hContrastHist,histContrast,'Contrast (%)');
%         plotHistogram(hFixationHist,fixationData/2,'Fixation Window (Deg)');
    end
end
function displayLLbarSRC(subjectName,expDates,protocolNames,folderSourceString,gridType,gridPositionLLBar,removeBreaks,removeIgnores)

%Fonts
fontSizeMedium=12;
textPosX = 0.5; textPosY = 1.25;

if iscell(expDates)
    allEOTCodes=[];
    allAttendLoc=[];
    for i=1:length(expDates)
        clear expDate protocolName
        expDate=expDates{i};
        protocolName=protocolNames{i};
        load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','LL.mat'));
        allEOTCodes = cat(2,allEOTCodes,LL.eotCode);
        allAttendLoc= cat(2,allAttendLoc,LL.attendLoc);
    end
else
    expDate=expDates;
    protocolName=protocolNames;
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','LL.mat')); % Single day
    allEOTCodes = [LL.eotCode];
    allAttendLoc= [LL.attendLoc];
end

% Right (0)
gridPositionLLBar_RIGHT = [gridPositionLLBar(1) gridPositionLLBar(2) ...
    gridPositionLLBar(3)/2 gridPositionLLBar(4)];


[~,~,numTrialsRight] = displayEOTCodes(gridPositionLLBar_RIGHT,allEOTCodes(allAttendLoc==0),protocolName,1,[],removeBreaks,removeIgnores); 
 text(textPosX,textPosY,[ 'Right (' num2str(numTrialsRight) ')'], ...
     'Units','Normalized','Rotation',90,'FontSize',fontSizeMedium,'HorizontalAlignment','center','color','b');
    
% Left (1)
gridPositionLLBar_LEFT = [gridPositionLLBar(1)+gridPositionLLBar(3)/2 gridPositionLLBar(2) ...
    gridPositionLLBar(3)/2 gridPositionLLBar(4)];
[~,~,numTrialsLeft] = displayEOTCodes(gridPositionLLBar_LEFT,allEOTCodes(allAttendLoc==1),protocolName,1,[],removeBreaks,removeIgnores);
 text(textPosX,textPosY,['Left (' num2str(numTrialsLeft) ')'], ...
     'Units','Normalized','Rotation',90,'FontSize',fontSizeMedium,'HorizontalAlignment','center');
end
% function plotHistogram(hHist,histContrast,xLabelStr)
% axes(hHist); %#ok<*MAXES>
% cla;
% hist(hHist,histContrast,100);
% text(0.4,0.9,[num2str(mean(histContrast)) ' +- ' num2str(std(histContrast))],'Units','Normalized');
% xlabel(xLabelStr);
% axis tight
% end
function dayString=getDayString(subjectName,expDates,protocolNames)

dayString = '';
for i=1:length(expDates)
    dayString = cat(2,dayString,[ num2str(i) ' ' subjectName expDates{i} protocolNames{i} '|']);
end
dayString = [dayString 'all days'];
end
% function [fixWindowSizeEyeStims,fixWindowSizeGoodStims] = getFixationWindowData(folderNameMain)
% % fixWindowSizeEyeStims - the fixation window size for each stimulus for
% % which we analyze the energy of the eye Data.
% % fixWindowSizeGoodStims - fixation window size for all good stimuli
% % Get the fixationWindowSizes
% load(fullfile(folderNameMain,'extractedData','BehaviorData.mat')); % returns the variable allTrials
% 
% % Get the stimResults
% load(fullfile(folderNameMain,'extractedData','stimResults.mat')); % returns the variable stimResults
% 
% % Get goodStimNums
% load(fullfile(folderNameMain,'extractedData','goodStimNums.mat')); % returns the variable goodStimNums
% 
% if exist(fullfile(folderNameMain,'extractedData','validStimAfterTarget.mat'),'file')
%     load (fullfile(folderNameMain,'extractedData','validStimAfterTarget.mat'));
%     goodStimNums(validStimuliAfterTarget)=[];  % Get rid of these stimuli
% end
% 
% stimPos = stimResults.stimPosition(goodStimNums);
% fixWindowSizeGoodStims = allTrials.fixWindowSize(stimResults.trialNumber(goodStimNums));
% 
% fixWindowSizeEyeStims = fixWindowSizeGoodStims(stimPos>1);
% end
function displayLLInfoSRCPsyAndReactInfo(subjectName,expDates,protocolNames,folderSourceString,gridType,...
   gridPositionTemporalInfo,gridPositionTargetInfo,gridPositionPsy,gridPositionReactTimes,convertOriValsInLogScale,hFig)

% This is the old program written for the MAC. It is kept only for the SRC
% protocol. Addidiotnal variables (targetInfo,psyInfo,reactInfo) are stored
% in extractedData/LLinfo.mat to allow this program to run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Color Names
rightColor = 'b'; %Right
leftColor  = 'k'; %Left

if ~iscell(expDates)
    [side0{1},side1{1},eotByType{1},colorNames,orientationValues{1},correctResults{1},xValsAll{1},reactTimesAll{1}]=getDataForSingleDay(subjectName,expDates,protocolNames,folderSourceString,gridType);
    numDays = length(expDates);
else
    numDays=length(expDates);
    side0=cell(1,numDays);
    side1=cell(1,numDays);
    eotByType=cell(1,numDays);
    orientationValues=cell(1,numDays);
    correctResults=cell(1,numDays);
    xValsAll=cell(1,numDays);
    reactTimesAll=cell(1,numDays);
    for i=1:numDays
        [side0{i},side1{i},eotByType{i},colorNames,orientationValues{i},correctResults{i},xValsAll{i},reactTimesAll{i}]=getDataForSingleDay(subjectName,expDates{i},protocolNames{i},folderSourceString,gridType);
    end
end

% Plotting routines
subplot('Position',gridPositionTemporalInfo);

[mSide0,stdSide0] = combineBlockData(side0);
[mSide1,stdSide1] = combineBlockData(side1);

errorbar(1:length(mSide0),mSide0,stdSide0,'color',rightColor,'Marker','o'); hold on;
errorbar(1:length(mSide1),mSide1,stdSide1,'color',leftColor,'Marker','o'); hold on;
plot(1:length(mSide0),mSide0,'color',rightColor,'Marker','o'); hold on;
plot(1:length(mSide1),mSide1,'color',leftColor,'Marker','o'); hold on;
legend('Right','Left','Location','NorthOutside');
hold off;
axis tight;
axisVals=axis;
axis ([0 axisVals(2) 0 axisVals(4)]);
xlabel('Block number'); ylabel('Number of trials');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position',[gridPositionTargetInfo(1)+gridPositionTargetInfo(3)/2 gridPositionTargetInfo(2) ...
    gridPositionTargetInfo(3)/2 gridPositionTargetInfo(4)]);

mEotByType = combineEotByType(eotByType);

for k=1:7
    plot(squeeze(mEotByType(k,1,:)),'color',colorNames{k});
    hold on;
    plot(squeeze(mEotByType(k,1,:)),'color',colorNames{k},'Marker','o');
end
hold off;
set(gca,'YTickLabel',[]);
xlabel('Target position'); title('Right');
%axis([0 8 0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position',[gridPositionTargetInfo(1) gridPositionTargetInfo(2) ...
    gridPositionTargetInfo(3)/2 gridPositionTargetInfo(4)]);
for k=1:7
    plot(squeeze(mEotByType(k,2,:)),'color',colorNames{k});
    hold on;
    plot(squeeze(mEotByType(k,2,:)),'color',colorNames{k},'Marker','o');
end
hold off;
xlabel('Target position');
title('Left');
%axis([0 8 0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Psychometric functions
numTFs = size(orientationValues{1},1);
dX = gridPositionPsy(3)/numTFs;

pThreshold = 0.5;

[allorientationValues,allCorrectResults] = combinePsyData(orientationValues,correctResults);

startPt = [3 1 1];
bothColor = 'r';
for i=1:numTFs
    subplot('Position',[gridPositionPsy(1)+(i-1)*dX gridPositionPsy(2) dX-0.002 gridPositionPsy(4)]);
    
    thres = zeros(1,2);
    for j=1:2  % attendLoc
        orientationValuesTMP = allorientationValues{i,j};
        if convertOriValsInLogScale
            numOri = length(unique(orientationValuesTMP));
            maxOriVal = max(orientationValuesTMP);
            minOriVal = min(orientationValuesTMP);
            orientationValuesTMP = log2(orientationValuesTMP./minOriVal);
        end
        correctResultsTMP  = allCorrectResults{i,j};
        
        
        if j==1
            if length(unique(orientationValuesTMP)) ==1
                plotFractionCorrent(orientationValuesTMP,correctResultsTMP,rightColor)
            else
            params = plotPsychometricFunction(orientationValuesTMP,correctResultsTMP,rightColor,startPt);
            end
        else
            if length(unique(orientationValuesTMP)) ==1
                plotFractionCorrent(orientationValuesTMP,correctResultsTMP,leftColor)
            else
            params = plotPsychometricFunction(orientationValuesTMP,correctResultsTMP,leftColor,startPt);
            end
        end
        if length(unique(orientationValuesTMP))>1
            thres(j) = wblinv(pThreshold/params(3),params(1),params(2));
        end
    end
    
    % Both sides combined
    orientationValuesTMP = [allorientationValues{i,1} allorientationValues{i,2}];
    if convertOriValsInLogScale
        numOri = length(unique(orientationValuesTMP));
        maxOriVal = max(orientationValuesTMP);
        minOriVal = min(orientationValuesTMP);
        orientationValuesTMP = log2(orientationValuesTMP./minOriVal);
    end
    correctResultsTMP  = [allCorrectResults{i,1} allCorrectResults{i,2}];
    if length(unique(orientationValuesTMP)) ==1
        plotFractionCorrent(orientationValuesTMP,correctResultsTMP,bothColor)
    else
    params = plotPsychometricFunction(orientationValuesTMP,correctResultsTMP,bothColor,startPt);
    thres(3) = wblinv(pThreshold/params(3),params(1),params(2));
    end
%    axis([0 7 0 1.05]);
    
    title(['TF: ' num2str(i)]);
    ylim([0 1])
    
    if length(unique(orientationValuesTMP))>1
        
        if convertOriValsInLogScale
            text(2,0.3, ['R: ' convertToOri(thres(1),numOri,maxOriVal,minOriVal)],'color',rightColor);
            text(2,0.2, ['L: ' convertToOri(thres(2),numOri,maxOriVal,minOriVal)],'color',leftColor);
            text(2,0.1, ['C: ' convertToOri(thres(3),numOri,maxOriVal,minOriVal)],'color',bothColor);
        else
            if i==1
                text(3,0.3, ['Right: ' num2str(round(thres(1),2))],'color',rightColor);
                text(3,0.2, ['Left: ' num2str(round(thres(2),2))],'color',leftColor);
                text(3,0.1, ['both: ' num2str(round(thres(3),2))],'color',bothColor);
            else
                text(15,0.3, ['Right: ' num2str(round(thres(1),2))],'color',rightColor);
                text(15,0.2, ['Left: ' num2str(round(thres(2),2))],'color',leftColor);
                text(15,0.1, ['both: ' num2str(round(thres(3),2))],'color',bothColor);
            end
        end
    end
    
    if i==1
        ylabel('fraction correct');
    else
        set(gca,'YTickLabel',[]);
    end
    
    hold off;
    

end

figName = fullfile(folderSourceString,['Behavior_' subjectName expDates protocolNames]);
saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This works only for a single day

dX = gridPositionReactTimes(3)/numTFs;

if numDays==1
    for i=1:numTFs
        subplot('Position',[gridPositionReactTimes(1)+(i-1)*dX gridPositionReactTimes(2) dX-0.002 gridPositionReactTimes(4)]);
        for j=1:2
            if j==1
                colorName=rightColor;
            else
                colorName=leftColor;
            end
            plot(xValsAll{1}{i,j},reactTimesAll{1}{i,j},'color',colorName,'Marker','o');
            hold on;
            if i==1
                ylabel('Reaction time (ms)');
            else
                set(gca,'YTickLabel',[]);
            end
        end
        ylim([0 1000]);
    end
else
    
% Option to combine this data is very difficult and can be implemented
% later
% [xValsCombined,mReactTimesAll,stdReactTimesAll] = combineReactionTimeData(xValsAll,reactTimesAll);
% 
% for i=1:numTFs
%     subplot('Position',[gridPositionReactTimes(1)+(i-1)*dX ...
%     gridPositionReactTimes(2) dX-0.002 gridPositionReactTimes(4)]);
% 
%     for j=1:2
%         
%         mReactTimes = squeeze(mReactTimesAll(i,j,:))';
%         stdReactTimes = squeeze(stdReactTimesAll(i,j,:))';
%         
%         if j==1
%             colorName=rightColor;
%         else
%             colorName=leftColor;
%         end
%         errorbar(xValsCombined,mReactTimes,stdReactTimes,'color',colorName); hold on;
%         plot(xValsCombined,mReactTimes,'color',colorName,'Marker','o');
%         
%         axis([0 7 0 600]);
%         
%         if i==1
%             ylabel('Reaction time (ms)');
%         else
%             set(gca,'YTickLabel',[]);
%         end
%         
%         if rem(i,2)==1
%             set(gca,'XTick',[1 3 5 7],'XTickLabel',[1.6 6.25 25 100]);
%             xlabel('Contrast (%)');
%         else
%             set(gca,'XTickLabel',[]);
%         end
%     end
%     hold off;
% end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [side0,side1,eotByType,colorNames,orientationValues,correctResults,xValAll,reactTimesAll]=getDataForSingleDay(subjectName,expDate,protocolName,folderSourceString,gridType)
        
load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','LL.mat')); %#ok<*LOAD>

% Temporal Info
% We get here the number of trials spent on each block
% 
R2L = find(diff([targetInfo.attendLoc])==1); lR2L = length(R2L);
L2R = find(diff([targetInfo.attendLoc])==-1); lL2R = length(L2R);
% R2L = find([targetInfo.attendLoc]==0); lR2L = length(R2L);
% L2R = find([targetInfo.attendLoc]==1); lL2R = length(L2R);

side0 = zeros(1,lR2L);
side1 = zeros(1,lL2R);

side0(1) = R2L(1); %
side1(1) = L2R(1)-R2L(1);

if lL2R>1
    for i=2:lL2R
        side0(i) = R2L(i)-L2R(i-1);
        side1(i) = L2R(i)-R2L(i);
    end
end

if lR2L>lL2R
    side0(lR2L) = R2L(lR2L)-L2R(lR2L-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Target Positions
targetIndices = [targetInfo.targetIndex];
allEOTCodes = [targetInfo.eotCode];
allAttendLocs = [targetInfo.attendLoc];
showEOTbar=0;

eotByType = zeros(7,2,max(targetIndices));

for i=1:max(targetIndices)
    
    for j=1:2
        clear eotCodes
        eotCodes = allEOTCodes(intersect(find(targetIndices==i),find(allAttendLocs==j-1)));
    
        if isempty(eotCodes)
            for k=1:7
                eotByType(k,j,i) = 0;
            end
        else
            [eotFraction,colorNames] = displayEOTCodes([],eotCodes,protocolName,showEOTbar,[]);
            for k=1:7
                eotByType(k,j,i) = eotFraction(k);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% psychometric functions
numTF = length(unique([psyInfo.temporalFreqIndex]));
orientationValues = cell(numTF,2);
correctResults  = cell(numTF,2);
for i=1:numTF
    for j=1:2
        clear tmp
        tmp = intersect(find([psyInfo.temporalFreqIndex]==i-1),find([psyInfo.attendLoc]==j-1));
        orientationValues{i,j} = [psyInfo(tmp).changeInOrientation];
        eotResults= [psyInfo(tmp).eotCode];
        correctResults{i,j} = (eotResults==0);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reaction times
xValAll = cell(numTF,2);
reactTimesAll  = cell(numTF,2);
for i=1:numTF
    uniqueOriVals = unique(orientationValues{i,1});

    for j=1:2
        clear tmp
        tmp = intersect(find([reactInfo.temporalFreqIndex]==i-1),find([reactInfo.attendLoc]==j-1));
        
        count=1;
        clear xVal reactTimes

        for k=1:length(uniqueOriVals)
            theseIndices = intersect(find([reactInfo.changeInOrientation]==uniqueOriVals(k)),tmp);
            if ~isempty(theseIndices)
                xVal(count)  = uniqueOriVals(k);
                reactTimes(count) = mean([reactInfo(theseIndices).reactTime]);
                count=count+1;
            end
        end
        
        xValAll{i,j} = xVal;
        reactTimesAll{i,j} = reactTimes;
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [expDates,protocolNames] = convertToCell(expDate,protocolName)
expDates{1} = expDate;
protocolNames{1} = protocolName;
end

function Oristr = convertToOri(oriIndex,numOri,maxOriVal,minOriVal) %#ok<*INUSL>
if oriIndex<=numOri
    Oristr = num2str(minOriVal*(2^(oriIndex)));
else
    disp('Ori index out of range');
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mBlockData,stdBlockData]=combineBlockData(blockData)
numDays = length(blockData);
maxBlocks=0; 
for i=1:numDays
    maxBlocks = max([maxBlocks length(blockData{i})]);
end

numTrialsPerBlock = cell(1,maxBlocks);

for i=1:numDays
    numBlocks = length(blockData{i});
    
    for j=1:numBlocks
        numTrialsPerBlock{j} = [numTrialsPerBlock{j} blockData{i}(j)];
    end
end
    
mBlockData = zeros(1,maxBlocks);
stdBlockData = zeros(1,maxBlocks);

for i=1:maxBlocks
    mBlockData(i) = mean(numTrialsPerBlock{i});
    stdBlockData(i) = std(numTrialsPerBlock{i});
end
end
function mEotByType = combineEotByType(eotByType)
numDays = length(eotByType);
sumEotByType=zeros(size(eotByType{1}));

for i=1:numDays
    sumEotByType = sumEotByType+eotByType{i};
end

mEotByType = sumEotByType/numDays;

end
function [allorientationValues,allCorrectResults] = combinePsyData(orientationValues,correctResults)
numDays = length(orientationValues);
numTFs = size(orientationValues{1},1);

allorientationValues = cell(numTFs,2);
allCorrectResults = cell(numTFs,2);
for i=1:numTFs
    for j=1:2
        allorientationValues{i,j} = [];
        allCorrectResults{i,j}  = [];
    end
end

for i=1:numTFs
    for j=1:2
        for k=1:numDays
            allorientationValues{i,j} = [allorientationValues{i,j} orientationValues{k}{i,j}];
            allCorrectResults{i,j}  = [allCorrectResults{i,j}  correctResults{k}{i,j}];
        end
    end
end

end
% function [xList,mReactTimeArray,stdReactTimeArray] = combineReactionTimeData(xValsAll,reactTimesAll)
% 
% numDays = length(reactTimesAll);
% [numTFs,numLocs] = size(reactTimesAll{1});
% 
% reactTimeArray=cell(numTFs,numLocs,7);
% for i=1:numTFs
%     for j=1:numLocs
%         for c=1:7
%             reactTimeArray{i,j,c} = [];
%         end
%     end
% end
% 
% for i=1:numTFs
%     for j=1:numLocs
%         for k=1:numDays
%             xValsThisCombination = (xValsAll{k}{i,j});
%             reactTimesThisCombination = reactTimesAll{k}{i,j};
%             
%             for a = 1:length(xValsThisCombination)
%                 reactTimeArray{i,j,xValsThisCombination(a)} = [reactTimeArray{i,j,xValsThisCombination(a)} reactTimesThisCombination(a)];
%             end
%         end
%     end
% end
% 
% mReactTimeArray=zeros(numTFs,numLocs,7);
% stdReactTimeArray=zeros(numTFs,numLocs,7);
% 
% for i=1:numTFs
%     for j=1:numLocs
%         for c=1:7
%             mReactTimeArray(i,j,c) = mean(reactTimeArray{i,j,c});
%             stdReactTimeArray(i,j,c) = std(reactTimeArray{i,j,c});
%         end
%     end
% end
% xList=1:7;
% end

function plotFractionCorrent(X,Y,colorName)
uniqueX = unique(X);
lX = length(uniqueX);
xVal = zeros(1,lX);
yVal = zeros(1,lX);
numVal = zeros(1,lX);
for i=1:lX
    xVal(i) = uniqueX(i);
    yVal(i) = mean(Y(X==uniqueX(i)));
    numVal(i) = length(find(X==uniqueX(i)));
end

plot(xVal,yVal,'Marker','o','color',colorName,'lineStyle','none'); hold on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileStr = getFileStr(subjectName,expDates,protocolNames,folderSourceString,gridType)

for i=1:length(expDates)
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDates{i},protocolNames{i},'extractedData','LL.mat'));
    
    fileStr(i).azimuth0Deg     = LL.azimuth0Deg; %#ok<*AGROW>
    fileStr(i).azimuth1Deg     = LL.azimuth1Deg;
    fileStr(i).elevation0Deg   = LL.elevation0Deg;
    fileStr(i).elevation1Deg   = LL.elevation1Deg;
    fileStr(i).orientation0Deg = LL.baseOrientation0Deg;
    fileStr(i).orientation1Deg = LL.baseOrientation1Deg;
    fileStr(i).spatialFreq0CPD = LL.spatialFreq0CPD;
    fileStr(i).spatialFreq1CPD = LL.spatialFreq1CPD;
    fileStr(i).sigmaDeg = LL.sigmaDeg;
    fileStr(i).radiusDeg = LL.radiusDeg;
end
end