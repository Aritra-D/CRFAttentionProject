function plotComparison

load('E:\Projects\Aritra_AttentionEEGProject\Figures\Mayo Project- Monkey V4 LFP Attention\figure_1_and_3_data\Figure1Dataset_allAllStimulatedOri23_tapers23.mat'); %#ok<LOAD>
close all;
hFig = figure(1);
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlotsFig.hPlot2 = getPlotHandles(1,2,[0.06 0.15 0.3 0.15],0.01,0.01,1);%linkaxes(hPlotsFig.hPlot2)

hPlotsFig.hPlot4 = getPlotHandles(1,2,[0.4 0.15 0.3 0.15],0.01,0.01,1);%linkaxes(hPlotsFig.hPlot4)

hPlotsFig.hPlot6 = getPlotHandles(1,1,[0.75 0.14 0.1 0.12],0.01,0.01,1);linkaxes(hPlotsFig.hPlot6)

psdData_BL = conv2Log(Figure1Dataset(1).psdData);
psdData_ST = conv2Log(Figure1Dataset(2).psdData);
psdData_TG = conv2Log(Figure1Dataset(3).psdData);

freqVals_ST = Figure1Dataset(2).freqVals;
freqVals_TG = Figure1Dataset(3).freqVals;


plot(hPlotsFig.hPlot2(1,1),freqVals_ST,10*(squeeze(mean(psdData_BL(1,:,:),2))-squeeze(mean(psdData_BL(1,:,:),2))),'k')
hold(hPlotsFig.hPlot2(1,1),'on')
plot(hPlotsFig.hPlot2(1,1),freqVals_ST,10*(squeeze(mean(psdData_ST(1,:,:),2))-squeeze(mean(psdData_ST(2,:,:),2))),'LineWidth',1.5,'color',[0.8500 0.3250 0.0980])

plot(hPlotsFig.hPlot2(1,2),freqVals_TG,10*(squeeze(mean(psdData_TG(1,:,:),2))-squeeze(mean(psdData_TG(1,:,:),2))),'k')
hold(hPlotsFig.hPlot2(1,2),'on')
plot(hPlotsFig.hPlot2(1,2),freqVals_TG,10*(squeeze(mean(psdData_TG(1,:,:),2))-squeeze(mean(psdData_TG(2,:,:),2))),'LineWidth',1.5,'color',[0.8500 0.3250 0.0980])


load('E:\Projects\Aritra_AttentionEEGProject\Figures\Mayo Project- Monkey V4 LFP Attention\figure_1_and_3_data\Figure3and4Dataset_allAllStimulatedOri23_tapers23_hiGamma122_198_ssvep20.mat');

alphaPower = conv2Log([Figure3and4Dataset(4).rawData{1} Figure3and4Dataset(4).rawData{2}]);
gammaPower = conv2Log([Figure3and4Dataset(3).rawData{1} Figure3and4Dataset(3).rawData{2}]);
ssvepPower = conv2Log([Figure3and4Dataset(5).rawData{1} Figure3and4Dataset(5).rawData{2}]);

deltaAlphaPower = 10*(alphaPower(:,1)-alphaPower(:,2));
deltaGammaPower = 10*(gammaPower(:,1)-gammaPower(:,2));
deltaSSVEPPower = 10*(ssvepPower(:,1)-ssvepPower(:,2));

mDeltaPower_alpha = -mean(deltaAlphaPower,1);semDeltaPower_alpha = std(deltaAlphaPower,[],1)./sqrt(size(deltaAlphaPower,1));
mDeltaPower_gamma = mean(deltaGammaPower,1);semDeltaPower_gamma = std(deltaGammaPower,[],1)./sqrt(size(deltaGammaPower,1));
mDeltaPower_SSVEP = mean(deltaSSVEPPower,1);semDeltaPower_SSVEP = std(deltaSSVEPPower,[],1)./sqrt(size(deltaSSVEPPower,1));

barPlotData = [mDeltaPower_alpha mDeltaPower_gamma mDeltaPower_SSVEP];
errorBarPlotData = [semDeltaPower_alpha semDeltaPower_gamma semDeltaPower_SSVEP];

colors = {'k','r','c'};
for iBar = 1:3
    b1 = bar(iBar,barPlotData(iBar),colors{iBar},'parent',hPlotsFig.hPlot6(1,1)); hold(hPlotsFig.hPlot6(1,1),'on')
end
errorbar(hPlotsFig.hPlot6(1,1),1:3,barPlotData,errorBarPlotData,'.','color','k')
set(hPlotsFig.hPlot6(1,1),'XTick',1:5);

dPowers(1,:) = deltaAlphaPower;
dPowers(2,:) = deltaGammaPower;
dPowers(3,:) = deltaSSVEPPower;

NeuralMeasures = {'alpha','gamma', 'SSVEP'}; %#ok<*NASGU>
for i=1:size(dPowers,1)
[~,pVals_ttest]=ttest(dPowers(i,:));
disp(['t-test' ':' NeuralMeasures{i} ' pVals = ' num2str(pVals_ttest)])
end

dPowers(1,:) = -dPowers(1,:); % making the delta alpha powers negative
allCombinations = nchoosek(1:size(dPowers,1),2);
for iComb=1:size(allCombinations,1)
    %            if strcmp(statTest,'RankSum')
    %                pVals(iComb) = ranksum(dPowers(allCombinations(iComb,1),:),dPowers(allCombinations(iComb,2),:));
    %            elseif strcmp(statTest,'t-test')
    [~,pVals(iComb)] = ttest(dPowers(allCombinations(iComb,1),:),dPowers(allCombinations(iComb,2),:));
        disp (['t-test' ': ' NeuralMeasures{allCombinations(iComb,1)} ' & ' NeuralMeasures{allCombinations(iComb,2)} ' pVals = ' num2str(pVals(iComb))])

    %            end
end
H = sigstar({[1,2],[1,3],[2,3]},pVals,0);

xlabel(hPlotsFig.hPlot2(1,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot2(1,1),'Change in Power (dB)');
title(hPlotsFig.hPlot2(1,1),'Stim Onset');
title(hPlotsFig.hPlot2(1,2),'PreTarget');
title(hPlotsFig.hPlot6(1,1),'PreTarget');
ylabel(hPlotsFig.hPlot6(1,1),'Change in Power (dB)');

% legend

tickLengthPlot = 1.5*get(hPlotsFig.hPlot2(1,1),'TickLength');

% set(hPlotsFig.hPlot1,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot2,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
% set(hPlotsFig.hPlot3,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot4,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
% set(hPlotsFig.hPlot5,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot6,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12,'xTick',1:3,'yTick',[-2 0 2])

% set(hPlotsFig.hPlot5(3,1),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);
% set(hPlotsFig.hPlot6(3,1),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);
% set(hPlotsFig.hPlot5(3,2),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);
% set(hPlotsFig.hPlot6(3,2),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);

% rescaleData(hPlotsFig.hPlot1(:,1),-1.000,1.250,[-10 5],12,0);
% rescaleData(hPlotsFig.hPlot1(:,2),-1.000,0,[-10 5],12,2);
% rescaleData(hPlotsFig.hPlot3(:,1),-1.000,1.250,[-10 5],12,0);
% rescaleData(hPlotsFig.hPlot3(:,2),-1.000,0,[-10 5],12,2);
rescaleData(hPlotsFig.hPlot2,0,100,[-5 5],12,0);
rescaleData(hPlotsFig.hPlot4,0,200,[-5 5],12,0);
rescaleData(hPlotsFig.hPlot6,0,4,[-2 2],12,0);
% rescaleData(hP

displayRange(hPlotsFig.hPlot2,[8 12],[-5 5],'k','solid-solid')
displayRange(hPlotsFig.hPlot2,[42 78],[-5 5],'m','solid-solid')
displayRange(hPlotsFig.hPlot2,[20 20],[-5 5],'g','solid-solid')

% displayRange(hPlotsFig.hPlot4,[8 12],[-5 5],'k','solid-solid')
% displayRange(hPlotsFig.hPlot4,[20 66],[-5 5],'m','solid-solid')
% displayRange(hPlotsFig.hPlot4(2:3,:),[23 23],[-5 5],'g','solid-solid')
% displayRange(hPlotsFig.hPlot4(2:3,:),[31 31],[-5 5],'c','solid-solid')


stringLabels{1} = 'alpha (8-12 Hz)';
stringLabels{2} = 'gamma (42-78 Hz)';
stringLabels{3} = 'SSVEP (20 Hz)';

set(hPlotsFig.hPlot6(1,1),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',14);

figName = fullfile('E:\','PlotComparison3');
saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')


end


% Draw lines for timeTange or FreqRange
function displayRange(plotHandles,range,yLims,colorName,lineStyle)
[nX,nY] = size(plotHandles);
%yLims = getYLims(plotHandles);
if ~exist('lineStyle','var')
    lineStyle = 'solid-solid';
end
yVals = yLims(1):(yLims(2)-yLims(1))/100:yLims(2);
xVals1 = range(1) + zeros(1,length(yVals));
xVals2 = range(2) + zeros(1,length(yVals));

for i=1:nX
    for j=1:nY
        hold(plotHandles(i,j),'on');
        if strcmp(lineStyle,'solid-solid')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineWidth',1);
        elseif strcmp(lineStyle,'solid-dash')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineStyle','--','LineWidth',1);
        end
    end
end
end

% get Y limits for an axis
function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end

% Rescale data
function rescaleData(plotHandles,xMin,xMax,yLims,labelSize,removeLabels)

[numRows,numCols] = size(plotHandles);
% labelSize=14;
for i=1:numRows
    for j=1:numCols
        hold(plotHandles(i,j),'on');
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && j==1)
            if removeLabels==1
                set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
            elseif removeLabels==2
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            else
                set(plotHandles(i,j),'fontSize',labelSize);
            end
        else
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        end
    end
end

% Remove Labels on the four corners
%set(plotHandles(1,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(1,numCols),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,numCols),'XTickLabel',[],'YTickLabel',[]);
end



