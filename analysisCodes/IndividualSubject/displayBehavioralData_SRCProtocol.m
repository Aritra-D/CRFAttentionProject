
function [side0,side1,eotByType,colorNames,contrastIndices,correctResults,xValAll,reactTimesAll]= displayBehavioralData_SRCProtocol(subjectName,expDate,protocolName,gridType,folderSourceString)

% LL File Info
LLFileName =  fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','LL.mat');

% Load LL File
if exist(LLFileName,'file')
%     load(LLFileName) %#ok<*LOAD>
% else
    frameRate = 100;
    folderDestinationString = folderSourceString;
    LLFileExistsFlag = saveLLData(subjectName,expDate,protocolName,folderSourceString,gridType,frameRate,folderDestinationString);
    if LLFileExistsFlag
        load(LLFileName)
    else
        error('LL file not found')
    end
end

% Temporal Info
% We get here the number of trials spent on each block

R2L = find(diff([targetInfo.attendLoc])==1); lR2L = length(R2L);
L2R = find(diff([targetInfo.attendLoc])==-1); lL2R = length(L2R);

side0 = zeros(1,lR2L);
side1 = zeros(1,lL2R);

side0(1) = R2L(1);
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

gridPositionTemporalInfo = [0.75 0.8 0.2 0.15];
gridPositionTargetInfo = [0.75 0.6 0.2 0.125];
gridPositionPsy = [0.75 0.225 0.2 0.2];
gridPositionReactTimes = [0.75 0.05 0.2 0.15];

% Target Positions
targetIndices = [targetInfo.targetIndex];
allEOTCodes = [targetInfo.eotCode];
allAttendLocs = [targetInfo.attendLoc];
showEOTbar=0;

%eottypes
% 0 - correct, 1 - wrong, 2-failed, 3-broke, 4-ignored, 5-False
% Alarm/quit, 6 - distracted, 7 - force quit

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
contrastIndices = cell(numTF,2);
correctResults  = cell(numTF,2);
oriValues = cell(numTF,2);
for i=1:numTF
    for j=1:2
        clear tmp
        tmp = intersect(find([psyInfo.temporalFreqIndex]==i-1),find([psyInfo.attendLoc]==j-1));
        contrastIndices{i,j} = [psyInfo(tmp).contrastIndex];
        oriValues{i,j} = [psyInfo(tmp).oriChangeVal];
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
        clear tmp
        tmp = intersect(find([reactInfo.temporalFreqIndex]==i-1),find([reactInfo.attendLoc]==j-1));
        
        count=1;
        clear xVal reactTimes
        for k=1:1
            theseIndices = intersect(find([reactInfo.contrastIndex]==k-1),tmp);
            if ~isempty(theseIndices)
                xVal(count)  = k-1; %#ok<*AGROW>
                reactTimes(count) = mean([reactInfo(theseIndices).reactTime]);
                count=count+1;
            end
        end
        
        xValAll{i,j} = xVal;
        reactTimesAll{i,j} = reactTimes;
    end
end

% Color Names
rightColor = 'b'; %Right
leftColor  = 'k'; %Left

% subplot(2,3,1)
subplot('Position',gridPositionTemporalInfo);

plot(1:length(side0),side0,'color',rightColor,'Marker','o'); hold on;
plot(1:length(side1),side1,'color',leftColor,'Marker','o'); hold on;
legend('out','in','Location','best');
hold off;
axis tight;
axisVals=axis;
axis ([0 axisVals(2) 0 axisVals(4)]);
xlabel('Block number'); ylabel('Number of trials');

% subplot(2,3,2)
subplot('Position',[gridPositionTargetInfo(1)+gridPositionTargetInfo(3)/2 gridPositionTargetInfo(2) ...
    gridPositionTargetInfo(3)/2 gridPositionTargetInfo(4)]);

for k=1:7
    plot(squeeze(eotByType(k,1,:)),'color',colorNames{k});
    hold on;
    plot(squeeze(eotByType(k,1,:)),'color',colorNames{k},'Marker','o');
end
hold off;
set(gca,'YTickLabel',[]);
xlabel('Target position'); title('out');
axis([0 8 0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,3,3);
subplot('Position',[gridPositionTargetInfo(1) gridPositionTargetInfo(2) ...
    gridPositionTargetInfo(3)/2 gridPositionTargetInfo(4)]);

for k=1:7
    plot(squeeze(eotByType(k,2,:)),'color',colorNames{k});
    hold on;
    plot(squeeze(eotByType(k,2,:)),'color',colorNames{k},'Marker','o');
end
hold off;
xlabel('Target position');
title('in');
axis([0 8 0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure(2)
% Psychometric functions
numTFs = size(contrastIndices,1);
dX = gridPositionPsy(3)/numTFs;

pThreshold = 0.5;

startPt = [3 1 1];

for i=1:numTFs
    subplot('Position',[gridPositionPsy(1)+(i-1)*dX gridPositionPsy(2) dX-0.002 gridPositionPsy(4)]);
    
    thres = zeros(1,2);
    for j=1:2  % attendLoc
        oriValsTMP = oriValues{i,j};
        correctResultsTMP  = correctResults{i,j};
        
        if j==1
            params = plotPsychometricFunction(oriValsTMP,correctResultsTMP,rightColor,startPt);
        else
            params = plotPsychometricFunction(oriValsTMP,correctResultsTMP,leftColor,startPt);
        end
        thres(j) = wblinv(pThreshold/params(3),params(1),params(2));
    end
    
    axis([0 max(unique(oriValsTMP)) 0 1.05]);
    
    title(['TF: ' convertToTemporalFreq(i-1)]);
    
    if (i<=6)
        text(4,0.2, ['out: ' num2str(thres(1))],'color',rightColor);
        text(4,0.1, ['in: '  num2str(thres(2))],'color',leftColor);
    else
        text(1,0.9, ['out: ' num2str(thres(1))],'color',rightColor);
        text(1,0.8, ['in: '  num2str(thres(2))],'color',leftColor);
    end
    
    if i==1
        ylabel('fraction correct');
    else
        set(gca,'YTickLabel',[]);
    end
    
    if rem(i,2)==1
%         set(gca,'XTick',[1 3 5 7],'XTickLabel',[1.6 6.25 25 100]);
    else
        set(gca,'XTickLabel',[]);
    end
    hold off;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dX = gridPositionReactTimes(3)/numTFs;
[xValsCombined,mReactTimesAll,stdReactTimesAll] = combineReactionTimeData(xValsAll,reactTimesAll);

for i=1:numTFs
    subplot('Position',[gridPositionReactTimes(1)+(i-1)*dX ...
    gridPositionReactTimes(2) dX-0.002 gridPositionReactTimes(4)]);

    for j=1:2
        
        mReactTimes = squeeze(mReactTimesAll(i,j,:))';
        stdReactTimes = squeeze(stdReactTimesAll(i,j,:))';
        
        if j==1
            colorName=rightColor;
        else
            colorName=leftColor;
        end
        errorbar(xValsCombined,mReactTimes,stdReactTimes,'color',colorName); hold on;
        plot(xValsCombined,mReactTimes,'color',colorName,'Marker','o');
        
        axis([0 7 0 600]);
        
        if i==1
            ylabel('Reaction time (ms)');
        else
            set(gca,'YTickLabel',[]);
        end
        
        if rem(i,2)==1
            set(gca,'XTick',[1 3 5 7],'XTickLabel',[1.6 6.25 25 100]);
            xlabel('Contrast (%)');
        else
            set(gca,'XTickLabel',[]);
        end
    end
    hold off;
end


end



function TFstr = convertToTemporalFreq(tfIndex)

if tfIndex==0
    TFstr='0';
elseif tfIndex<3
    TFstr = num2str(round((21.33*0.75^(3-tfIndex))));
elseif tfIndex==7
    TFstr = '50';
else 
    disp('Temporal frequency index out of range');
end

end
function Cstr = convertToContrast(c)
    
    if c<=0
        Cstr = '0';
    else
        Cstr = num2str(100/2^(7-c));
    end
end


