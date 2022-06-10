function plotBehaviorSummary_SRCLongProtocols_Attention(subjectIdx)

close all;
if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

protocolType = 'SRC-Long';
fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_BehaviorData.mat']);
if exist(fileName, 'file')
    behavior_Attention = load(fileName,'BehaviorData_SRCLong_StimDesc').BehaviorData_SRCLong_StimDesc;
else
    error('Consolidated Behavior Data not Found- Refer to plotBehavior_SRCProtocols to generate consoliadated Behavior Data')
end

hFig =  figure(1);
set(hFig,'units','normalized','outerPosition',[0 0 1 1]);

% Plots
hPlot1 = getPlotHandles(1,3,[0.05 0.65 0.9 0.3],0.05, 0.01,0,0);
hPlot2 = getPlotHandles(1,3,[0.05 0.15 0.9 0.3],0.05, 0.01,0,0);

% Color Names
% rightColor = 'b'; % Right
% leftColor  = 'k'; % Left
% bothColor  = 'r'; % Right & Left Combined

orientationValues = behavior_Attention.orientationValues(subjectIdx);
correctResults = behavior_Attention.correctResults(subjectIdx);
% xVals = behavior_Attention.xValsAll(subjectIdx);
responseTimes = behavior_Attention.reactTimesAll(subjectIdx);

numTFs = size(orientationValues{1},1);
numAttentionLoc =  size(orientationValues{1},2);

deltaOri = zeros(length(subjectIdx),length(numTFs),length(numAttentionLoc));
accuracyVals = zeros(length(subjectIdx),length(numTFs),length(numAttentionLoc));
reactTimes = zeros(length(subjectIdx),length(numTFs),length(numAttentionLoc));

for iTF=1:numTFs % Temporal Frequency
    for iAttendLoc=1:2  % attendLoc
        for iSub = 1: length(subjectIdx)
            orientationValuesTMP = orientationValues{iSub}{iTF,iAttendLoc};
            correctResultsTMP = correctResults{iSub}{iTF,iAttendLoc};
            [deltaOri(iSub,iTF,iAttendLoc),accuracyVals(iSub,iTF,iAttendLoc)] = computeFractionCorrent(orientationValuesTMP,correctResultsTMP);
            reactTimes(iSub,iTF,iAttendLoc) = responseTimes{iSub}{iTF,iAttendLoc};
        end
    end
end

% mean and sem calculated across subjects
mAccuracy = flip(squeeze(mean(accuracyVals,1)),2)';
semAccuracy = flip(squeeze(std(accuracyVals,[],1)./sqrt(size(accuracyVals,1))),2)';

mDeltaOri = flip(squeeze(mean(deltaOri,1)),2)';
semDeltaOri = flip(squeeze(std(deltaOri,[],1)./sqrt(size(deltaOri,1))),2)';

mResponseTime = flip(squeeze(mean(reactTimes,1)),2)';
semResponseTime = flip(squeeze(std(reactTimes,[],1)./sqrt(size(reactTimes,1))),2)';

stringLabels = {'Attend Left-Static','Attend Right-Static',...
                'Attend Left-12 Hz', 'Attend Right-12 Hz',...
                'Attend Left-16 Hz', 'Attend Right-16 Hz'};

barPlotData_Performance = 100*mAccuracy(:);
barPlotData_semPerformance = 100*semAccuracy(:);

barPlotData_ResponseTime = mResponseTime(:);
barPlotData_semResponseTime = semResponseTime(:);

barPlotData_DeltaOri = mDeltaOri(:);
barPlotData_semDeltaOri = semDeltaOri(:);

colors = {'k','b','k','b','k','b'};

for i= 1:length(barPlotData_Performance)
    bar(i,barPlotData_Performance(i),colors{i},'parent',hPlot1(1,1)); hold(hPlot1(1,1), 'on');
    bar(i,barPlotData_ResponseTime(i),colors{i},'parent',hPlot1(1,2)); hold(hPlot1(1,2), 'on');
    bar(i,barPlotData_DeltaOri(i),colors{i},'parent',hPlot1(1,3)); hold(hPlot1(1,3), 'on');
end
errorbar(hPlot1(1),barPlotData_Performance,barPlotData_semPerformance,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot1(2),barPlotData_ResponseTime,barPlotData_semResponseTime,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot1(3),barPlotData_DeltaOri,barPlotData_semDeltaOri,'LineStyle','none','color','k','LineWidth',1.5);

tickLengthPlot = 1.5*get(hPlot1(1,1),'TickLength');

for i=1:3
    set(hPlot1(i),'XTick',1:6);
    set(hPlot1(i),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',14,'box','off','TickDir','out','TickLength',tickLengthPlot);
end
set(hPlot1(2),'YTick',0:200:800,'YTickLabel',0:200:800,'XTickLabelRotation',45,'fontSize',14,'box','off','TickDir','out','TickLength',tickLengthPlot);


ylim(hPlot1(1),[0 100]); title(hPlot1(1),'Behavioral Performance'); ylabel(hPlot1(1),'Accuracy (%)')
ylim(hPlot1(2),[0 800]); title(hPlot1(2),'Response Time'); ylabel(hPlot1(2),'Response Time (ms)')
ylim(hPlot1(3),[0 15]); title(hPlot1(3),'\Delta Orientation (Stim->Target)'); ylabel(hPlot1(3),'\Delta Ori (Degree)')
end

function [xVal,yVal] = computeFractionCorrent(X,Y)
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
end