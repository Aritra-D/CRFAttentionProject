function plotBehavior_SRCProtocols(protocolType,subjectIdx,convertOriValsInLogScale)

close all;
if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_BehaviorData.mat']);
if exist(fileName, 'file')
    load(fileName) %#ok<*LOAD>
else
    % Psychophysics Task
    protocolSubType = 'Psychophysics';
    protocolType1 = [protocolType '_' protocolSubType];
    getTFIndexFromStimDescFlag = 1;
    
    % SRC Psychophysics: Target with five Orientations Change
    [BehaviorData_SRCLong_Psychophysics_StimDesc] = ...
        getBehaviorData_SRCLongProtocols(protocolType1,gridType,getTFIndexFromStimDescFlag);
    
    getTFIndexFromStimDescFlag = 0;
    [BehaviorData_SRCLong_Psychophysics_TargetDesc] = ...
        getBehaviorData_SRCLongProtocols(protocolType1,gridType,getTFIndexFromStimDescFlag);
    
    % SRC Main Attention Task: Target with Single Orientation Change
    protocolSubType = '';
    protocolType2 = [protocolType protocolSubType];
    getTFIndexFromStimDescFlag = 1;
    [BehaviorData_SRCLong_StimDesc] = ...
        getBehaviorData_SRCLongProtocols(protocolType2,gridType,getTFIndexFromStimDescFlag);
    
    getTFIndexFromStimDescFlag = 0;
    [BehaviorData_SRCLong_TargetDesc] = ...
        getBehaviorData_SRCLongProtocols(protocolType2,gridType,getTFIndexFromStimDescFlag);
    
    save(fileName,'BehaviorData_SRCLong_Psychophysics_StimDesc','BehaviorData_SRCLong_Psychophysics_TargetDesc','BehaviorData_SRCLong_StimDesc','BehaviorData_SRCLong_TargetDesc');
end

% Plots
% Color Names
rightColor = 'b'; %Right
leftColor  = 'k'; %Left
bothColor = 'r';

for iParamInfoType = 1:2 % 1-Correct TF Indices % 2-Wrong TF Indices
    
    hFig = figure(iParamInfoType);
    set(hFig,'units','normalized','outerposition',[0 0 1 1]);
    hPlot1 = getPlotHandles(2,3,[0.65 0.55 0.3 0.4],0.01,0.05,1);
    hPlot2 = getPlotHandles(2,3,[0.65 0.07 0.3 0.4],0.01,0.05,1);
    
    
    switch iParamInfoType
        case 1
            behavior_psych = BehaviorData_SRCLong_Psychophysics_StimDesc;
            behavior_att = BehaviorData_SRCLong_StimDesc;
        case 2
            behavior_psych = BehaviorData_SRCLong_Psychophysics_TargetDesc;
            behavior_att = BehaviorData_SRCLong_TargetDesc;
    end
    
    for iProt = 1:2 % 1- Psychophysics Protocol, 2- Attention Protocol
        switch iProt
            case 1
                orientationValues = behavior_psych.orientationValues(subjectIdx);
                correctResults = behavior_psych.correctResults(subjectIdx);
                xVals = behavior_psych.xValsAll(subjectIdx);
                responseTimes = behavior_psych.reactTimesAll(subjectIdx); 
                hPlot_Accuracy = hPlot1(1,:);
                hPlot_ResponseTime = hPlot1(2,:);
            case 2
                orientationValues = behavior_att.orientationValues(subjectIdx);
                correctResults = behavior_att.correctResults(subjectIdx);
                xVals = behavior_att.xValsAll(subjectIdx);
                responseTimes = behavior_att.reactTimesAll(subjectIdx);
                hPlot_Accuracy = hPlot2(1,:);
                hPlot_ResponseTime = hPlot2(2,:);
        end
        
%         % Plots the number of trials to complete each block
%         errorbar(1:length(Side0),mSide0,stdSide0,'color',rightColor,'Marker','o'); hold on;
%         errorbar(1:length(Side1),mSide1,stdSide1,'color',leftColor,'Marker','o'); hold on;
%         plot(1:length(mSide0),mSide0,'color',rightColor,'Marker','o'); hold on;
%         plot(1:length(mSide1),mSide1,'color',leftColor,'Marker','o'); hold on;
%         legend('Right','Left','Location','NorthOutside');
%         hold off;
%         axis tight;
%         axisVals=axis;
%         axis ([0 axisVals(2) 0 axisVals(4)]);
%         xlabel('Block number'); ylabel('Number of trials');
%         
%         % EOT Results by different EOT Types for both Sides (0-Right, 1-Left) for
%         % different target positions
%         mEotByType = combineEotByType(eotByType);
%         
%         for k=1:7
%             plot(squeeze(mEotByType(k,1,:)),'color',colorNames{k});
%             hold on;
%             plot(squeeze(mEotByType(k,1,:)),'color',colorNames{k},'Marker','o');
%         end
%         hold off;
%         set(gca,'YTickLabel',[]);
%         xlabel('Target position'); title('Right');
%         %axis([0 8 0 1]);
%         
%         for k=1:7
%             plot(squeeze(mEotByType(k,2,:)),'color',colorNames{k});
%             hold on;
%             plot(squeeze(mEotByType(k,2,:)),'color',colorNames{k},'Marker','o');
%         end
%         hold off;
%         xlabel('Target position');
%         title('Left');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Psychometric functions
        numTFs = size(orientationValues{1},1);
%         dX = gridPositionPsy(3)/numTFs;
        
        pThreshold = 0.5;
        
        [allorientationValues,allCorrectResults] = combinePsyData(orientationValues,correctResults);
        
        startPt = [3 1 1];

        for i=1:numTFs % Temporal Frequency
%             subplot('Position',[gridPositionPsy(1)+(i-1)*dX gridPositionPsy(2) dX-0.002 gridPositionPsy(4)]);
            subplot(hPlot_Accuracy(1,i));
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
                if length(unique(orientationValuesTMP))>2
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
            elseif length(unique(orientationValuesTMP)) ==2
                orientationValuesTMP = orientationValuesTMP(1)*(ones(1,length(orientationValuesTMP)));
                plotFractionCorrent(orientationValuesTMP,correctResultsTMP,bothColor)

            else
                params = plotPsychometricFunction(orientationValuesTMP,correctResultsTMP,bothColor,startPt);
                thres(3) = wblinv(pThreshold/params(3),params(1),params(2));
            end
            %    axis([0 7 0 1.05]);
            
            title(['TF: ' num2str(i)]);
            ylim([0 1])
            
            if length(unique(orientationValuesTMP))>2
                
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
        
        % Response Times
        for i=1:numTFs
            subplot(hPlot_ResponseTime(1,i));
            for j=1:2
                if j==1
                    colorName=rightColor;
                else
                    colorName=leftColor;
                end
                plot(xVals{1}{i,j},responseTimes{1}{i,j},'color',colorName,'Marker','o');
                hold on;
                if i==1
                    ylabel('Reaction time (ms)');
                else
                    set(gca,'YTickLabel',[]);
                end
            end
            ylim([0 1000]);
        end
    end
end
end

function  BehaviorData = getBehaviorData_SRCLongProtocols(protocolType,gridType,getTFIndexFromStimDescFlag)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);

numSubjects=length(subjectNames);
side0=cell(1,numSubjects);
side1=cell(1,numSubjects);
eotByType=cell(1,numSubjects);
orientationValues=cell(1,numSubjects);
correctResults=cell(1,numSubjects);
xValsAll=cell(1,numSubjects);
reactTimesAll=cell(1,numSubjects);
for i=1:numSubjects
    [side0{i},side1{i},eotByType{i},colorNames,orientationValues{i},correctResults{i},xValsAll{i},reactTimesAll{i}]=getDataForSingleSubject(subjectNames{i},expDates{i},protocolNames{i},dataFolderSourceString,gridType,getTFIndexFromStimDescFlag);
end

BehaviorData.side0 = side0;
BehaviorData.side1 = side1;
BehaviorData.eotByType = eotByType;
BehaviorData.colorNames = colorNames;
BehaviorData.orientationValues = orientationValues;
BehaviorData.correctResults =correctResults;
BehaviorData.xValsAll= xValsAll;
BehaviorData.reactTimesAll = reactTimesAll;

end


function [side0,side1,eotByType,colorNames,orientationValues,correctResults,xValAll,reactTimesAll]=getDataForSingleSubject(subjectName,expDate,protocolName,dataFolderSourceString,gridType,getTFIndexFromStimDescFlag)

load(fullfile(dataFolderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','LL.mat')); %#ok<*LOAD>

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
        if getTFIndexFromStimDescFlag == 0
            tmp = intersect(find([psyInfo.temporalFreqIndex]==i-1),find([psyInfo.attendLoc]==j-1));
        elseif getTFIndexFromStimDescFlag ==1
            tmp = intersect(find([psyInfo.temporalFreqIndex_stimDesc]==i-1),find([psyInfo.attendLoc]==j-1));
        end
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
    for j=1:2
        if getTFIndexFromStimDescFlag == 1 && j==2 && i==2 % For Attend Left, For i(TF) == 2, the orientation displayed was for i(TF) == 3
            uniqueOriVals = unique(orientationValues{i+1,1});
        elseif getTFIndexFromStimDescFlag == 1 && j==2 && i==3 % For Attend Left, For i(TF) == 3, the orientation displayed was for i(TF) == 2
            uniqueOriVals = unique(orientationValues{i-1,1});
        else
            uniqueOriVals = unique(orientationValues{i,1});
        end
        clear tmp
        if getTFIndexFromStimDescFlag == 0
            tmp = intersect(find([reactInfo.temporalFreqIndex]==i-1),find([reactInfo.attendLoc]==j-1));
        elseif getTFIndexFromStimDescFlag ==1
            tmp = intersect(find([reactInfo.temporalFreqIndex_stimDesc]==i-1),find([reactInfo.attendLoc]==j-1));
        end
        
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

