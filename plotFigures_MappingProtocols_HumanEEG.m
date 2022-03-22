function plotFigures_MappingProtocols_HumanEEG(protocolType,analysisType,plotFSDataFlag,plotCombinedData)
% close all;

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

if analysisType == 1
    
elseif analysisType == 2
    for iRef =1:2
        energyData.analysisDataBL{iRef}(1,3) = energyData.analysisDataBL_trialAvg{iRef}(1,3);
        energyData.analysisDataBL{iRef}(1,4) = energyData.analysisDataBL_trialAvg{iRef}(1,4);
        energyData.analysisDataST{iRef}(1,3) = energyData.analysisDataST_trialAvg{iRef}(1,3);
        energyData.analysisDataST{iRef}(1,4) = energyData.analysisDataST_trialAvg{iRef}(1,4);
    end
end

% Plotting
% Display Properties
if plotCombinedData ==0
    hFig = figure(1);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlot1 = getPlotHandles(2,3,[0.07 0.1 0.4 0.8],0.04,0.06,1);
    hPlot2 = getPlotHandles(2,3,[0.57 0.1 0.4 0.8],0.04,0.06,1);
    
elseif plotCombinedData ==1
    hFig = figure(2);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlot1 = getPlotHandles(2,3,[0.07 0.1 0.4 0.8],0.04,0.06,1);
    hPlot2 = getPlotHandles(2,3,[0.57 0.1 0.4 0.8],0.04,0.06,1);
end


electrodeList_Unipolar = getElectrodeList('actiCap64','unipolar',1);
electrodeList_Bipolar = getElectrodeList('actiCap64','bipolar',1);

highPriorityUnipolarElectrodes = getHighPriorityElectrodes('actiCap64');
highPriorityBipolarElectrodes = [93 94 101 102 96 97 111 107 112];

elecUnipolarList = [24 29 57 61 26 31 58 63];
elecList_Unipolar_Left = [24 29 57 61];
elecList_Unipolar_Right = [26 31 58 63];

elecBipolarList = [93 94 101 96 97 102];
elecList_Bipolar_Left = [93 94 101];
elecList_Bipolar_Right = [96 97 102];

stimList = 0:2:8;
colors = {'b','r','g'};

FSData = [-2.1 0.57 6.26];
semFSData = [0 0 0];

if plotCombinedData ==0
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
        dPowerVals_AvgAcrossSubjects = mean(dPowerValsSubjectWise_AvgAcrossElecs,1);
        sem_dPowerVals_AcrossSubjects = std(dPowerValsSubjectWise_AvgAcrossElecs,[],1)./size(dPowerValsSubjectWise_AvgAcrossElecs,1);
        if plotFSDataFlag
            dPowerVals_AvgAcrossSubjects = [FSData(iFreqRange) dPowerVals_AvgAcrossSubjects]; 
            sem_dPowerVals_AcrossSubjects = [semFSData(iFreqRange) sem_dPowerVals_AcrossSubjects]; 
        end
        errorbar(hPlot1(iElecSide,iFreqRange),stimList,dPowerVals_AvgAcrossSubjects,sem_dPowerVals_AcrossSubjects,'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
        
    end
    
end


% Main Loop for plotting Bipolar
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
        dPowerVals_AvgAcrossSubjects = mean(dPowerValsSubjectWise_AvgAcrossElecs,1);
        sem_dPowerVals_AcrossSubjects = std(dPowerValsSubjectWise_AvgAcrossElecs,[],1)./size(dPowerValsSubjectWise_AvgAcrossElecs,1);
        if plotFSDataFlag
            dPowerVals_AvgAcrossSubjects = [FSData(iFreqRange) dPowerVals_AvgAcrossSubjects]; 
            sem_dPowerVals_AcrossSubjects = [semFSData(iFreqRange) sem_dPowerVals_AcrossSubjects]; 
        end

        errorbar(hPlot2(iElecSide,iFreqRange),stimList,dPowerVals_AvgAcrossSubjects,sem_dPowerVals_AcrossSubjects,'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
    end
end

tickLength = 2*get(hPlot1(1,1),'TickLength');
xTickLabels = {'FS','2','4','6','8'};
set(hPlot1,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14,'Xlim',[-2 10],'xTick',0:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)
set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14,'Xlim',[-2 10],'xTick',0:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)

ylim(hPlot1(1,1),[-3 3]);ylim(hPlot1(2,1),[-3 0])
ylim(hPlot2(1,1),[-3 3]);ylim(hPlot2(2,1),[-3 0])

ylim(hPlot1(1,2),[-0.5 1]);ylim(hPlot1(2,2),[-0.5 1])
ylim(hPlot2(1,2),[-0.5 1]);ylim(hPlot2(2,2),[-0.5 1])

ylim(hPlot1(1,3),[0 10]);ylim(hPlot1(2,3),[-0.5 8])
ylim(hPlot2(1,3),[0 10]);ylim(hPlot2(2,3),[-0.5 8])

xlabel(hPlot1(2,1),'azi/ele/diam (degree)')
xlabel(hPlot2(2,1),'azi/ele/diam (degree)')

ylabel(hPlot1(1,1),{'Left Elecs','Change in Power (dB)'})
ylabel(hPlot1(2,1),{'Right Elecs','Change in Power (dB)'})
ylabel(hPlot2(1,1),{'Left Elecs','Change in Power (dB)'})
ylabel(hPlot2(2,1),{'Right Elecs','Change in Power (dB)'})

title(hPlot1(1,1),'alpha (8-12 Hz)'); title(hPlot2(1,1),'alpha (8-12 Hz)')
title(hPlot1(1,2),'gamma (20-66 Hz)'); title(hPlot2(1,2),'gamma (20-66 Hz)')
title(hPlot1(1,3),'SSVEP'); title(hPlot2(1,3),'SSVEP')

textH1 = getPlotHandles(1,1,[0.2 0.95 0.01 0.01]);
textH2 = getPlotHandles(1,1,[0.7 0.95 0.01 0.01]);


textString1 = 'Unipolar, N_S_U_B = 11,';

textString2 = 'Bipolar, N_S_U_B = 11';

set(textH1,'Visible','Off'); set(textH2,'Visible','Off')
text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH1);
text(0.35,1.15,textString2,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH2);

figName = fullfile(folderSourceString,[ 'allSubjects, N_11_',protocolType, num2str(tapers(2))]);
saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')

elseif plotCombinedData ==1
    
    
    for iFreqRange = 1:length(freqRanges)-1
        clear dataBL dataST
        if  iFreqRange == 3
            for iElec = 1:length(elecUnipolarList)
                if iElec == 1 || iElec == 2|| iElec == 3|| iElec == 4
                    dataBL(:,:,iElec) = energyData.analysisDataBL{1,1}{1,4}(:,:,elecUnipolarList(iElec)); %#ok<*AGROW>
                    dataST(:,:,iElec) = energyData.analysisDataST{1,1}{1,4}(:,:,elecUnipolarList(iElec));
                elseif iElec == 5 || iElec == 6|| iElec == 7|| iElec == 8
                    dataBL(:,:,iElec)= energyData.analysisDataBL{1,1}{1,3}(:,:,elecUnipolarList(iElec));
                    dataST(:,:,iElec) = energyData.analysisDataST{1,1}{1,3}(:,:,elecUnipolarList(iElec));
                end
            end
        else
            dataBL = energyData.analysisDataBL{1,1}{iFreqRange}(:,:,elecUnipolarList);
            dataST = energyData.analysisDataST{1,1}{iFreqRange}(:,:,elecUnipolarList);
        end
        
        dPowerValsSubjectWise_AvgAcrossElecs = 10*(squeeze(mean(dataST-dataBL,3)));
        dPowerVals_AvgAcrossSubjects = mean(dPowerValsSubjectWise_AvgAcrossElecs,1);
        sem_dPowerVals_AcrossSubjects = std(dPowerValsSubjectWise_AvgAcrossElecs,[],1)./size(dPowerValsSubjectWise_AvgAcrossElecs,1);
        if plotFSDataFlag
            dPowerVals_AvgAcrossSubjects = [FSData(iFreqRange) dPowerVals_AvgAcrossSubjects];
            sem_dPowerVals_AcrossSubjects = [semFSData(iFreqRange) sem_dPowerVals_AcrossSubjects];
        end
        errorbar(hPlot1(1,iFreqRange),stimList,dPowerVals_AvgAcrossSubjects,sem_dPowerVals_AcrossSubjects,'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
        
    end
    
% Main Loop for plotting Bipolar

    for iFreqRange = 1:length(freqRanges)-1
        clear dataBL dataST
        if  iFreqRange == 3
            for iElec = 1:length(elecBipolarList)
                if iElec == 1 || iElec == 2|| iElec == 3
                    dataBL(:,:,iElec) = energyData.analysisDataBL{1,2}{1,4}(:,:,elecBipolarList(iElec)); %#ok<*AGROW>
                    dataST(:,:,iElec) = energyData.analysisDataST{1,2}{1,4}(:,:,elecBipolarList(iElec));
                elseif iElec == 4 || iElec == 5|| iElec == 6
                    dataBL(:,:,iElec)= energyData.analysisDataBL{1,2}{1,3}(:,:,elecBipolarList(iElec));
                    dataST(:,:,iElec) = energyData.analysisDataST{1,2}{1,3}(:,:,elecBipolarList(iElec));
                end
            end
        else
            dataBL = energyData.analysisDataBL{1,2}{iFreqRange}(:,:,elecUnipolarList);
            dataST = energyData.analysisDataST{1,2}{iFreqRange}(:,:,elecUnipolarList);
        end

        
        dPowerValsSubjectWise_AvgAcrossElecs = 10*(squeeze(mean(dataST-dataBL,3)));
        dPowerVals_AvgAcrossSubjects = mean(dPowerValsSubjectWise_AvgAcrossElecs,1);
        sem_dPowerVals_AcrossSubjects = std(dPowerValsSubjectWise_AvgAcrossElecs,[],1)./size(dPowerValsSubjectWise_AvgAcrossElecs,1);
        if plotFSDataFlag
            dPowerVals_AvgAcrossSubjects = [FSData(iFreqRange) dPowerVals_AvgAcrossSubjects];
            sem_dPowerVals_AcrossSubjects = [semFSData(iFreqRange) sem_dPowerVals_AcrossSubjects]; 
        end

        errorbar(hPlot2(1,iFreqRange),stimList,dPowerVals_AvgAcrossSubjects,sem_dPowerVals_AcrossSubjects,'-o','color','k','MarkerSize',10,'MarkerEdgeColor',colors{iFreqRange},'MarkerFaceColor',colors{iFreqRange},'LineWidth',1.5)
    end


tickLength = 2*get(hPlot1(1,1),'TickLength');
xTickLabels = {'FS','2','4','6','8'};
set(hPlot1,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14,'Xlim',[-2 10],'xTick',0:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)
set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14,'Xlim',[-2 10],'xTick',0:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)

ylim(hPlot1(1,1),[-3 3]);ylim(hPlot1(2,1),[-3 0])
ylim(hPlot2(1,1),[-3 3]);ylim(hPlot2(2,1),[-3 0])

ylim(hPlot1(1,2),[-0.5 1]);ylim(hPlot1(2,2),[-0.5 1])
ylim(hPlot2(1,2),[-0.5 1]);ylim(hPlot2(2,2),[-0.5 1])

ylim(hPlot1(1,3),[0 10]);ylim(hPlot1(2,3),[-0.5 8])
ylim(hPlot2(1,3),[0 10]);ylim(hPlot2(2,3),[-0.5 8])

xlabel(hPlot1(2,1),'azi/ele/diam (degree)')
xlabel(hPlot2(2,1),'azi/ele/diam (degree)')

ylabel(hPlot1(1,1),{'Left Elecs','Change in Power (dB)'})
ylabel(hPlot1(2,1),{'Right Elecs','Change in Power (dB)'})
ylabel(hPlot2(1,1),{'Left Elecs','Change in Power (dB)'})
ylabel(hPlot2(2,1),{'Right Elecs','Change in Power (dB)'})

title(hPlot1(1,1),'alpha (8-12 Hz)'); title(hPlot2(1,1),'alpha (8-12 Hz)')
title(hPlot1(1,2),'gamma (20-66 Hz)'); title(hPlot2(1,2),'gamma (20-66 Hz)')
title(hPlot1(1,3),'SSVEP'); title(hPlot2(1,3),'SSVEP')

textH1 = getPlotHandles(1,1,[0.2 0.95 0.01 0.01]);
textH2 = getPlotHandles(1,1,[0.7 0.95 0.01 0.01]);


textString1 = 'Unipolar, N_S_U_B = 11,';

textString2 = 'Bipolar, N_S_U_B = 11';

set(textH1,'Visible','Off'); set(textH2,'Visible','Off')
text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH1);
text(0.35,1.15,textString2,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH2);

figName = fullfile(folderSourceString,[ 'allSubjects, N_11_',protocolType, num2str(tapers(2))]);
saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')
    
    
end

end

