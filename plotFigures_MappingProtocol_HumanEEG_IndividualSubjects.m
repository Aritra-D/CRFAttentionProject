function plotFigures_MappingProtocol_HumanEEG_IndividualSubjects(protocolType)

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-0.5 0];
timingParamters.stRange = [0.25 0.75];
timingParamters.erpRange = [0 0.25];

freqRanges{1} = [8 12]; % alpha
freqRanges{2} = [20 66]; % gamma
freqRanges{3} = [24 24];  % SSVEP Left Stim
freqRanges{4} = [32 32];  % SSVEP Right Stim
numFreqs = length(freqRanges); %#ok<*NASGU>

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_tapers_' num2str(tapers(2)) '.mat']);
if exist(fileName, 'file')
    load(fileName) %#ok<*LOAD>
else
    [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = ...
        getData_MappingProtocols(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'fftData','energyData','energyDataTF','badHighPriorityElecs','badElecs')
end

% Plotting
% Display Properties
hFig = figure(1);
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlot1 = getPlotHandles(11,3,[0.07 0.1 0.4 0.8],0.04,0.01,1); %linkaxes(hPlot1(:,1));linkaxes(hPlot1(:,2));linkaxes(hPlot1(:,3));
hPlot2 = getPlotHandles(11,3,[0.57 0.1 0.4 0.8],0.04,0.01,1); %linkaxes(hPlot2(:,1));linkaxes(hPlot2(:,2));linkaxes(hPlot2(:,3));

hFig2 = figure(2);
set(hFig2,'units','normalized','outerposition',[0 0 1 1])
hPlot3 = getPlotHandles(11,3,[0.07 0.1 0.4 0.8],0.04,0.01,1);%linkaxes(hPlot3(:,1));linkaxes(hPlot3(:,2));linkaxes(hPlot3(:,3));
hPlot4 = getPlotHandles(11,3,[0.57 0.1 0.4 0.8],0.04,0.01,1);%linkaxes(hPlot4(:,1));linkaxes(hPlot4(:,2));linkaxes(hPlot4(:,3));

electrodeList_Unipolar = getElectrodeList('actiCap64','unipolar',1);
electrodeList_Bipolar = getElectrodeList('actiCap64','bipolar',1);

highPriorityUnipolarElectrodes = getHighPriorityElectrodes('actiCap64');
highPriorityBipolarElectrodes = [93 94 101 102 96 97 111 107 112];

elecList_Unipolar_Left = [24 29 57 61];
elecList_Unipolar_Right = [26 31 58 63];

elecList_Bipolar_Left = [93 94 101];
elecList_Bipolar_Right = [96 97 102];

stimList = 2:2:8;
colors = {'b','r','g'};

% Main Loop for plotting Unipolar
for iElecSide = 1:2
    if iElecSide ==1
        elecList = elecList_Unipolar_Left;
    elseif iElecSide ==2
        elecList = elecList_Unipolar_Right;
    end
    
    for iFreqRange = 1:length(freqRanges)-1
        clear dataBL dataST
        
        if iElecSide == 1 && iFreqRange == 3
            dataBL = energyData.analysisDataBL{1,1}{1,4}(:,:,elecList);
            dataST = energyData.analysisDataST{1,1}{1,4}(:,:,elecList);
        elseif iElecSide == 2 && iFreqRange == 3
            dataBL = energyData.analysisDataBL{1,1}{1,3}(:,:,elecList);
            dataST = energyData.analysisDataST{1,1}{1,3}(:,:,elecList);
        else
            dataBL = energyData.analysisDataBL{1,1}{iFreqRange}(:,:,elecList);
            dataST = energyData.analysisDataST{1,1}{iFreqRange}(:,:,elecList);
        end
        
        dPowerValsSubjectWise_AvgAcrossElecs = 10*(squeeze(mean(dataST-dataBL,3)));
        sem_dPowerValsSubjectWise_AcrossElecs = std(10*(dataST-dataBL),[],3)./size(dataST-dataBL,3);
        
        if iElecSide ==1
            for iSub = 1:size(dPowerValsSubjectWise_AvgAcrossElecs,1)
                errorbar(hPlot1(iSub,iFreqRange),stimList,dPowerValsSubjectWise_AvgAcrossElecs(iSub,:),sem_dPowerValsSubjectWise_AcrossElecs(iSub,:),'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
            end
        elseif iElecSide ==2
            for iSub = 1:size(dPowerValsSubjectWise_AvgAcrossElecs,1)
                errorbar(hPlot2(iSub,iFreqRange),stimList,dPowerValsSubjectWise_AvgAcrossElecs(iSub,:),sem_dPowerValsSubjectWise_AcrossElecs(iSub,:),'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
            end
        end
    end
end


% Main Loop for plotting Unipolar
for iElecSide = 1:2
    if iElecSide ==1
        elecList = elecList_Bipolar_Left;
    elseif iElecSide ==2
        elecList = elecList_Bipolar_Right;
    end
    
    for iFreqRange = 1:length(freqRanges)-1
        clear dataBL dataST
        
        if iElecSide == 1 && iFreqRange == 3
            dataBL = energyData.analysisDataBL{1,2}{1,4}(:,:,elecList);
            dataST = energyData.analysisDataST{1,2}{1,4}(:,:,elecList);
        elseif iElecSide == 2 && iFreqRange == 3
            dataBL = energyData.analysisDataBL{1,2}{1,3}(:,:,elecList);
            dataST = energyData.analysisDataST{1,2}{1,3}(:,:,elecList);
        else
            dataBL = energyData.analysisDataBL{1,2}{iFreqRange}(:,:,elecList);
            dataST = energyData.analysisDataST{1,2}{iFreqRange}(:,:,elecList);
        end
        
        dPowerValsSubjectWise_AvgAcrossElecs = 10*(squeeze(mean(dataST-dataBL,3)));
        sem_dPowerValsSubjectWise_AcrossElecs = std(10*(dataST-dataBL),[],3)./size(dataST-dataBL,3);
        
        if iElecSide ==1
            for iSub = 1:size(dPowerValsSubjectWise_AvgAcrossElecs,1)
                errorbar(hPlot3(iSub,iFreqRange),stimList,dPowerValsSubjectWise_AvgAcrossElecs(iSub,:),sem_dPowerValsSubjectWise_AcrossElecs(iSub,:),'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
            end
        elseif iElecSide ==2
            for iSub = 1:size(dPowerValsSubjectWise_AvgAcrossElecs,1)
                errorbar(hPlot4(iSub,iFreqRange),stimList,dPowerValsSubjectWise_AvgAcrossElecs(iSub,:),sem_dPowerValsSubjectWise_AcrossElecs(iSub,:),'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
            end
        end
    end
end

tickLength = 2*get(hPlot1(1,1),'TickLength');
set(hPlot1,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14)
set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14)
set(hPlot3,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14)
set(hPlot4,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14)

yLims{1} = getYLims(hPlot1(:,1));
yLims{2} = getYLims(hPlot3(:,2));
yLims{3} = getYLims(hPlot4(:,3));

rescaleData(hPlot1(:,1),0,10,yLims{1},10)
rescaleData(hPlot1(:,2),0,10,yLims{2},10)
rescaleData(hPlot1(:,3),0,10,yLims{3},10)

rescaleData(hPlot2(:,1),0,10,yLims{1},10)
rescaleData(hPlot2(:,2),0,10,yLims{2},10)
rescaleData(hPlot2(:,3),0,10,yLims{3},10)

rescaleData(hPlot3(:,1),0,10,yLims{1},10)
rescaleData(hPlot3(:,2),0,10,yLims{2},10)
rescaleData(hPlot3(:,3),0,10,yLims{3},10)


rescaleData(hPlot4(:,1),0,10,yLims{1},10)
rescaleData(hPlot4(:,2),0,10,yLims{2},10)
rescaleData(hPlot4(:,3),0,10,yLims{3},10)

% ylim(hPlot1(1,1),[-6 0]);ylim(hPlot1(2,1),[-6 0])
% ylim(hPlot2(1,1),[-6 0]);ylim(hPlot2(2,1),[-6 0])
% ylim(hPlot3(1,1),[-6 0]);ylim(hPlot3(2,1),[-6 0])
% ylim(hPlot4(1,1),[-6 0]);ylim(hPlot4(2,1),[-6 0])
% 
% ylim(hPlot1(1,2),[-0.2 0.1]);ylim(hPlot1(2,2),[-0.2 0.1])
% ylim(hPlot2(1,2),[-0.2 0.1]);ylim(hPlot2(2,2),[-0.2 0.1])
% ylim(hPlot3(1,2),[-0.2 0.1]);ylim(hPlot3(2,2),[-0.2 0.1])
% ylim(hPlot4(1,2),[-0.2 0.1]);ylim(hPlot4(2,2),[-0.2 0.1])
% 
% ylim(hPlot1(1,3),[-0.5 2]);ylim(hPlot1(2,3),[-0.5 2])
% ylim(hPlot2(1,3),[-0.5 2]);ylim(hPlot2(2,3),[-0.5 2])
% ylim(hPlot3(1,3),[-0.5 2]);ylim(hPlot3(2,3),[-0.5 2])
% ylim(hPlot4(1,3),[-0.5 2]);ylim(hPlot4(2,3),[-0.5 2])

% xlabel(hPlot1(2,1),'azi/ele/diam (degree)')
% xlabel(hPlot2(2,1),'azi/ele/diam (degree)')
% xlabel(hPlot3(2,1),'azi/ele/diam (degree)')
% xlabel(hPlot4(2,1),'azi/ele/diam (degree)')
% 
% ylabel(hPlot1(1,1),{'Left Elecs','Change in Power (dB)'})
% ylabel(hPlot1(2,1),{'Right Elecs','Change in Power (dB)'})
% ylabel(hPlot2(1,1),{'Left Elecs','Change in Power (dB)'})
% ylabel(hPlot2(2,1),{'Right Elecs','Change in Power (dB)'})

% title(hPlot1(1,1),'alpha (8-12 Hz)'); title(hPlot2(1,1),'alpha (8-12 Hz)')
% title(hPlot1(1,2),'gamma (30-80 Hz)'); title(hPlot2(1,2),'gamma (30-80 Hz)')
% title(hPlot1(1,3),'SSVEP'); title(hPlot2(1,3),'SSVEP')
% 
% textH1 = getPlotHandles(1,1,[0.2 0.95 0.01 0.01]);
% textH2 = getPlotHandles(1,1,[0.7 0.95 0.01 0.01]);
% 
% 
% textString1 = 'Unipolar, N_S_U_B = 11,';
% 
% textString2 = 'Bipolar, N_S_U_B = 11';
% 
% set(textH1,'Visible','Off'); set(textH2,'Visible','Off')
% text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH1);
% text(0.35,1.15,textString2,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH2);
% 
% figName = fullfile(folderSourceString,[ 'allSubjects, N_11_',protocolType, num2str(tapers(2))]);
% saveas(hFig,[figName '.fig'])
% print(hFig,[figName '.tif'],'-dtiff','-r600')


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
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineWidth',1.5);
        elseif strcmp(lineStyle,'solid-dash')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
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
function rescaleData(plotHandles,xMin,xMax,yLims,labelSize)

[numRows,numCols] = size(plotHandles);
% labelSize=14;
for i=1:numRows
    for j=1:numCols
        hold(plotHandles(i,j),'on');
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && rem(j,2)==1)
            if j==1
                set(plotHandles(i,j),'fontSize',labelSize);
            elseif j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==0 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
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
