function plotBehaviorSummary_SRCLongProtocols_Attention(subjectIdx,getTFIndexFromTargetDescFlag,statTest)

close all;
if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
% if ~exist('gridType','var');            gridType='EEG';      end

protocolType = 'SRC-Long';
fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_BehaviorData.mat']);
if exist(fileName, 'file')
    if getTFIndexFromTargetDescFlag
    behavior_Attention = load(fileName,'BehaviorData_SRCLong_TargetDesc').BehaviorData_SRCLong_TargetDesc;
    else
    behavior_Attention = load(fileName,'BehaviorData_SRCLong_StimDesc').BehaviorData_SRCLong_StimDesc;
    end
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
    
    bar(i,barPlotData_Performance(i),colors{i},'parent',hPlot2(1,1)); hold(hPlot2(1,1), 'on');
    bar(i,barPlotData_ResponseTime(i),colors{i},'parent',hPlot2(1,2)); hold(hPlot2(1,2), 'on');
    bar(i,barPlotData_DeltaOri(i),colors{i},'parent',hPlot2(1,3)); hold(hPlot2(1,3), 'on');
end
errorbar(hPlot1(1),barPlotData_Performance,barPlotData_semPerformance,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot1(2),barPlotData_ResponseTime,barPlotData_semResponseTime,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot1(3),barPlotData_DeltaOri,barPlotData_semDeltaOri,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot2(1),barPlotData_Performance,barPlotData_semPerformance,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot2(2),barPlotData_ResponseTime,barPlotData_semResponseTime,'LineStyle','none','color','k','LineWidth',1.5);
errorbar(hPlot2(3),barPlotData_DeltaOri,barPlotData_semDeltaOri,'LineStyle','none','color','k','LineWidth',1.5);

tickLengthPlot = 1.5*get(hPlot1(1,1),'TickLength');

for i=1:3
    set(hPlot1(i),'XTick',1:6);
    set(hPlot1(i),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',14,'box','off','TickDir','out','TickLength',tickLengthPlot);
        set(hPlot2(i),'XTick',1:6);
    set(hPlot2(i),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',14,'box','off','TickDir','out','TickLength',tickLengthPlot);

end
set(hPlot1(2),'YTick',0:200:800,'YTickLabel',0:200:800,'XTickLabelRotation',45,'fontSize',14,'box','off','TickDir','out','TickLength',tickLengthPlot);
set(hPlot2(2),'YTick',0:200:800,'YTickLabel',0:200:800,'XTickLabelRotation',45,'fontSize',14,'box','off','TickDir','out','TickLength',tickLengthPlot);

ylim(hPlot1(1),[0 100]); title(hPlot1(1),'Behavioral Performance'); ylabel(hPlot1(1),'Accuracy (%)')
ylim(hPlot1(2),[0 800]); title(hPlot1(2),'Response Time'); ylabel(hPlot1(2),'Response Time (ms)')
ylim(hPlot1(3),[0 15]); title(hPlot1(3),'\Delta Orientation (Stim->Target)'); ylabel(hPlot1(3),'\Delta Ori (Degree)')
ylim(hPlot2(1),[0 100]); title(hPlot2(1),'Behavioral Performance'); ylabel(hPlot2(1),'Accuracy (%)')
ylim(hPlot2(2),[0 800]); title(hPlot2(2),'Response Time'); ylabel(hPlot2(2),'Response Time (ms)')
ylim(hPlot2(3),[0 15]); title(hPlot2(3),'\Delta Orientation (Stim->Target)'); ylabel(hPlot2(3),'\Delta Ori (Degree)')

attLocs = flip([1 2]); % 1-Right; 2-Left
count = 1;

for iTF = 1:size(accuracyVals,2)
    for iAttLoc=1:size(accuracyVals,3)
        accuracy_SubWise(:,count) = squeeze(accuracyVals(:,iTF,attLocs(iAttLoc))); %#ok<*AGROW>
        reactTimes_SubWise(:,count) = squeeze(reactTimes(:,iTF,attLocs(iAttLoc)));
        deltaOri_SubWise(:,count) = squeeze(deltaOri(:,iTF,attLocs(iAttLoc)));
        count = count+1;
    end
end

% Set up Statistical Tests
Condition{1} = 'AttL-Static';
Condition{2} = 'AttR-Static';
Condition{3} = 'AttL-12Hz';
Condition{4} = 'AttR-12Hz';
Condition{5} = 'AttL-16Hz';
Condition{6} = 'AttR-16Hz';

BehaviorParameters{1} = 'accuracy';
BehaviorParameters{2} = 'RT';
BehaviorParameters{3} = 'dOri';


allCombinations = nchoosek(1:length(Condition),2);
for i=1:3
    switch i
        case 1; statData = accuracy_SubWise';
        case 2; statData = reactTimes_SubWise';
        case 3; statData = deltaOri_SubWise';
    end
for iComb=1:size(allCombinations,1)
    if strcmp(statTest,'RankSum')
        pVals(iComb) = ranksum(statData(allCombinations(iComb,1),:),statData(allCombinations(iComb,2),:));
    elseif strcmp(statTest,'t-test')
        [~,pVals(iComb)] = ttest(statData(allCombinations(iComb,1),:),statData(allCombinations(iComb,2),:));
    end
    disp ([BehaviorParameters{i} ': ' statTest ': ' Condition{allCombinations(iComb,1)} ' & ' Condition{allCombinations(iComb,2)} ' pVals = ' num2str(pVals(iComb))])
end
end

annotation('textbox',[0 0.92 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','A','fontWeight','bold','fontSize',28);
annotation('textbox',[0.315 0.92 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','B','fontWeight','bold','fontSize',28);
annotation('textbox',[0.630 0.92 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','C','fontWeight','bold','fontSize',28);


% colors = jet(size(accuracy_SubWise,1));
% 
% for iSub = 1:size(accuracy_SubWise,1)
% plot(hPlot2(1,1),1:size(accuracy_SubWise,2),100*(squeeze(accuracy_SubWise(iSub,:))),'-o','color',colors(iSub,:,:)); hold(hPlot2(1),'on');
% plot(hPlot2(1,2),1:size(reactTimes_SubWise,2),squeeze(reactTimes_SubWise(iSub,:)),'-o','color',colors(iSub,:,:)); hold(hPlot2(1),'on');
% plot(hPlot2(1,3),1:size(deltaOri_SubWise,2),squeeze(deltaOri_SubWise(iSub,:)),'-o','color',colors(iSub,:,:)); hold(hPlot2(1),'on');
% 
% end

figName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\Behavior\','BehaviorSummary_N_26_SRCAttention');
saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')

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