% Plots Gamma power in Bipolar Ref Scheme; prior to finalizing of Thesis
% and Paper
function plotFigures_SFORIProtocols_HumanEEG(protocolType,...
    SSVEPAnalysisMethod,removeBadElectrodeData,subjectIdx,topoplot_style)

close all;

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-0.5 0];
timingParamters.stRange = [0.25 0.75];
timingParamters.erpRange = [0 0.25];

freqRanges{1} = [8 12];    % alpha
freqRanges{2} = [25 70];   % gamma
freqRanges{3} = [24 24];   % SSVEP Left Stim
freqRanges{4} = [32 32];   % SSVEP Right Stim
freqRanges{5} = [26 34];   % Slow Gamma
freqRanges{6} = [44 56];   % Fast Gamma
freqRanges{7} = [102 250]; % High Gamma

numFreqs = length(freqRanges); %#ok<*NASGU>
fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',...
    [protocolType '_tapers_' num2str(tapers(2)) '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz.mat']);
if exist(fileName, 'file')
    load(fileName,'energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = ...
        getData_SFORIProtocols(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'fftData','energyData','energyDataTF','freqRanges','badHighPriorityElecs','badElecs')
end

if SSVEPAnalysisMethod == 2
    for iRef =1:2
        energyData.dataBL{iRef}(:,:,2,:) = energyData.dataBL_trialAvg{iRef}(:,:,2,:);
        energyData.dataST{iRef}(:,:,2,:) = energyData.dataST_trialAvg{iRef}(:,:,2,:);
        energyData.dataBL_maxGamma{iRef}(:,:,2,:) = energyData.dataBL_trialAvg_maxGamma{iRef}(:,:,2,:);
        energyData.dataST_maxGamma{iRef}(:,:,2,:) = energyData.dataST_trialAvg_maxGamma{iRef}(:,:,2,:);
        
        energyData.analysisDataBL{iRef}(1,3) = energyData.analysisDataBL_trialAvg{iRef}(1,3);
        energyData.analysisDataST{iRef}(1,3) = energyData.analysisDataST_trialAvg{iRef}(1,3);
        energyData.analysisDataBL{iRef}(1,4) = energyData.analysisDataBL_trialAvg{iRef}(1,4);
        energyData.analysisDataST{iRef}(1,4) = energyData.analysisDataST_trialAvg{iRef}(1,4);
        
        energyData.analysisDataBL_maxGamma{iRef}(1,3) = energyData.analysisDataBL_trialAvg_maxGamma{iRef}(1,3);
        energyData.analysisDataST_maxGamma{iRef}(1,3) = energyData.analysisDataST_trialAvg_maxGamma{iRef}(1,3);
        energyData.analysisDataBL_maxGamma{iRef}(1,4) = energyData.analysisDataBL_trialAvg_maxGamma{iRef}(1,4);
        energyData.analysisDataST_maxGamma{iRef}(1,4) = energyData.analysisDataST_trialAvg_maxGamma{iRef}(1,4);
        
    end
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iRef = 1:2
            clear badElecsTMP
            badElecsTMP = badElecs{iRef}{subjectIdx(iSub)};
            
            if exist('erpData','var')
                % removing ERP data for Bad Electrodes
                erpData.dataBL{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
                erpData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
                erpData.analysisData_BL{iRef}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                erpData.analysisData_ST{iRef}(subjectIdx(iSub),:,badElecsTMP) = NaN;
            end
            
            % removing Energy data (PSD & Power) for Bad Electrodes
            energyData.dataBL{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            energyData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            energyData.dataBL_maxGamma{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            energyData.dataST_maxGamma{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            
            for iFreqRanges = 1: length(freqRanges)
                energyData.analysisDataBL{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                energyData.analysisDataST{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                energyData.analysisDataBL_maxGamma{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                energyData.analysisDataST_maxGamma{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;

            end
        end
    end
end

nanFlag = 'omitnan';

% Plots
hFig1 = figure(1); 
set(hFig1,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(5,2,[0.1 0.05, 0.2 0.9],0.02,0.04,0);
hPlot2 = getPlotHandles(2,2,[0.4 0.55, 0.2 0.4],0.02,0.04,0);
hPlot3 = getPlotHandles(2,2,[0.4 0.07, 0.2 0.4],0.02,0.04,0);

hPlot4 = getPlotHandles(2,2,[0.7 0.55, 0.2 0.4],0.02,0.04,0);
hPlot5 = getPlotHandles(2,2,[0.7 0.07, 0.2 0.4],0.02,0.04,0);

fontSizeLarge = 14; tickPlotLength = [0.025 0];
showMode = 'dots';
% Cap Layout & Ref Scheme related Info
capLayout = {'actiCap64'};
cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

electrodeList_Unipolar = getElectrodeList('actiCap64','unipolar',1);
electrodeList_Bipolar = getElectrodeList('actiCap64','bipolar',1);
elecUnipolarList =  [24 29 57 61 26 31 58 63];
elecBipolarList = [93 94 101 96 97 102];

neuralMeasures = [1 2 5 6 4]; % Neural Measures 1:Alpha, 2: Slow Gamma, 3: Fast Gamma, 4: SSVEP 24 Hz; 4: SSVEP 32 Hz;
colormap(jet);
colorAxis_alpha = [-2 2];
colorAxis_gamma = [-1 1.5];
if SSVEPAnalysisMethod == 1
    colorAxis_ssvep = [-1 10];
elseif SSVEPAnalysisMethod == 2
    colorAxis_ssvep = [-1 20];
end
colors = {'k','r',[0.4940 0.1840 0.5560],'m','c'};


% Main Loop for Topoplots

for i=1:2 % 1- all SF-Ori conditions, 2- max Gamma SF-Ori condition
    switch i
        case 1
            BLPower = energyData.analysisDataBL;
            STPower = energyData.analysisDataST;
        case 2
            BLPower = energyData.analysisDataBL_maxGamma;
            STPower = energyData.analysisDataST_maxGamma;
    end
    
   
    for j = 1: length(neuralMeasures) % 1- alpha, 2- gamma, 3- slow gamma, 4- fast gamma, 5- SSVEP
        if j==1
            BLPowerTopoTMP = squeeze(BLPower{1,1}{1,neuralMeasures(j)}(:,1,:));
            STPowerTopoTMP = squeeze(STPower{1,1}{1,neuralMeasures(j)}(:,1,:));
            colorRange = colorAxis_alpha; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
            
        elseif j==2|| j==3|| j==4
            BLPowerTopoTMP = squeeze(BLPower{1,2}{1,neuralMeasures(j)}(:,1,:));
            STPowerTopoTMP = squeeze(STPower{1,2}{1,neuralMeasures(j)}(:,1,:));
            colorRange = colorAxis_gamma; chanLocs = chanlocs_Bipolar; showElecs = elecBipolarList;
        elseif j==5
            BLPowerTopoTMP = squeeze(BLPower{1,1}{1,neuralMeasures(j)}(:,2,:));
            STPowerTopoTMP = squeeze(STPower{1,1}{1,neuralMeasures(j)}(:,2,:));
            colorRange = colorAxis_ssvep; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
        end
        
        topoPlotDataTMP = 10*(squeeze(mean(log10(STPowerTopoTMP),1,nanFlag)) - squeeze(mean(log10(BLPowerTopoTMP),1,nanFlag)));
        subplot(hPlot1(j,i)); cla; hold on;
        topoplot_murty(topoPlotDataTMP,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataTMP); 
        caxis(colorRange); cBar = colorbar;
        
        if j==5
            cTicks = [colorRange(1) 0 colorRange(2)/2 colorRange(2)]; 
        else
            cTicks = [colorRange(1) 0 colorRange(2)]; cBar = colorbar;
        end
        tickPlotLength = get(hPlot1(1,1),'TickLength'); fontSize = 12;
        set(cBar,'Ticks',cTicks,'tickLength',4*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
        if i==2 && j==5
            cBar.Label.String ='\Delta Power (dB)'; cBar.Label.FontSize = 14;
        end
        
        topoplot_murty([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecs);

    end
end

for iRef= 1:2
    switch iRef
        case 1; elecList = elecUnipolarList;
        case 2; elecList = elecBipolarList;
    end
    for i=1:2 % 1- all SF-Ori conditions, 2- max Gamma SF-Ori condition
        switch i
            case 1
                BLPSD = energyData.dataBL;
                STPSD = energyData.dataST;
            case 2
                BLPSD = energyData.dataBL_maxGamma;
                STPSD = energyData.dataST_maxGamma;
        end
        
        for iTF = 1:2
            BLpsdTMP = squeeze(mean(squeeze(BLPSD{1,iRef}(:,elecList,iTF,:)),2,nanFlag));
            STpsdTMP = squeeze(mean(squeeze(STPSD{1,iRef}(:,elecList,iTF,:)),2,nanFlag));
            psdBLTMP = squeeze(mean(log10(BLpsdTMP),1,nanFlag));
            psdSTTMP = squeeze(mean(log10(STpsdTMP),1,nanFlag));
            deltapsdTMP = 10*(squeeze(mean(log10(STpsdTMP),1,nanFlag)) - squeeze(mean(log10(BLpsdTMP),1,nanFlag)));
            if iTF== 1
                plot(hPlot2(iRef,i),energyData.freqVals,psdBLTMP,'g'); hold (hPlot2(iRef,i),'on')
                plot(hPlot2(iRef,i),energyData.freqVals,psdSTTMP,'k');
                plot(hPlot2(iRef,i),energyData.freqVals,deltapsdTMP,'b');
            elseif iTF==2
                plot(hPlot3(iRef,i),energyData.freqVals,psdBLTMP,'g'); hold (hPlot3(iRef,i),'on')
                plot(hPlot3(iRef,i),energyData.freqVals,psdSTTMP,'k');
                plot(hPlot3(iRef,i),energyData.freqVals,deltapsdTMP,'b');
            end
        end
    end
end

for iRef= 1:2
    switch iRef
        case 1; elecList = elecUnipolarList;
        case 2; elecList = elecBipolarList;
    end
    for i=1:2 % 1- all SF-Ori conditions, 2- max Gamma SF-Ori condition
        switch i
            case 1
                BLPower = energyData.analysisDataBL;
                STPower = energyData.analysisDataST;
            case 2
                BLPower = energyData.analysisDataBL_maxGamma;
                STPower = energyData.analysisDataST_maxGamma;
        end
        
        for iTF = 1:2
            for j = 1:length(neuralMeasures)
                BLPowerTMP = squeeze(mean(squeeze(BLPower{1,iRef}{1,neuralMeasures(j)}(:,iTF,elecList)),2,nanFlag));
                STPowerTMP = squeeze(mean(squeeze(STPower{1,iRef}{1,neuralMeasures(j)}(:,iTF,elecList)),2,nanFlag));
                deltaPowerTMP = 10*(log10(STPowerTMP) - log10(BLPowerTMP));
                mDeltaPowerTMP = mean(deltaPowerTMP,1,nanFlag);
                semDeltaPowerTMP = std(deltaPowerTMP,[],1,nanFlag)./sqrt(size(deltaPowerTMP,1));
                
                mBars(j) = mDeltaPowerTMP; %#ok<*AGROW>
                errorBars(j) = semDeltaPowerTMP;
                
                if iTF== 1
                    if j== 5
                    else
                        subplot(hPlot4(iRef,i)); hold(hPlot4(iRef,i),'on')
                        barPlot = bar(j,mDeltaPowerTMP);
                        barPlot.FaceColor = colors{j};
                    end

                    
                elseif iTF== 2
                    subplot(hPlot5(iRef,i)); hold(hPlot5(iRef,i),'on')
                    barPlot = bar(j,mDeltaPowerTMP);
                    barPlot.FaceColor = colors{j};
                end

            end
            if iTF== 1
            errorbar(hPlot4(iRef,i),1:length(mBars)-1,mBars(1:4),errorBars(1:4),'.','color','k');
            elseif iTF== 2
            errorbar(hPlot5(iRef,i),1:length(mBars),mBars,errorBars,'.','color','k');
            end
        end
    end
end

fontSize = 12;
title(hPlot1(1,1),'all SF-Ori','fontSize',fontSize)
title(hPlot1(1,2),'Max Gamma SF-Ori','fontSize',fontSize)

title(hPlot2(1,1),'all SF-Ori','fontSize',fontSize)
title(hPlot2(1,2),'Max Gamma SF-Ori','fontSize',fontSize)

title(hPlot4(1,1),'all SF-Ori','fontSize',fontSize)
title(hPlot4(1,2),'Max Gamma SF-Ori','fontSize',fontSize)

linkaxes(hPlot2); ylim(hPlot2(1,1),[-4 4]); xlim(hPlot2(1,1),[0 100]);

linkaxes(hPlot4); ylim(hPlot4(1,1),[-4 4]); xlim(hPlot4(1,1),[0 6]);

if SSVEPAnalysisMethod ==1 
linkaxes(hPlot5); ylim(hPlot5(1,1),[-4 11]); xlim(hPlot5(1,1),[0 6]);
elseif SSVEPAnalysisMethod ==2
linkaxes(hPlot5); ylim(hPlot5(1,1),[-8 25]); xlim(hPlot5(1,1),[0 6]);
end
lineWidth = 1.5;

for i=1:2
    for j=1:2
        set(hPlot2(i,j),'box','off','fontSize',fontSize)
        set(hPlot4(i,j),'box','off','fontSize',fontSize)
        xline(hPlot2(i,j),8,'k'); xline(hPlot2(i,j),12,'k')
        xline(hPlot2(i,j),freqRanges{2}(1)-1,'--r'); xline(hPlot2(i,j),freqRanges{2}(2)+1,'--r')
        xline(hPlot2(i,j),freqRanges{5}(1),'color',colors{3}); xline(hPlot2(i,j),freqRanges{5}(2),'color',colors{3})
        xline(hPlot2(i,j),freqRanges{6}(1),'m'); xline(hPlot2(i,j),freqRanges{6}(2),'m')
        yline(hPlot2(i,j),0,'--k','lineWidth',lineWidth)
    end
end
if SSVEPAnalysisMethod ==1
    yLims = [-4 10];
linkaxes(hPlot3); ylim(hPlot3(1,1),yLims); xlim(hPlot3(1,1),[0 100]);
elseif SSVEPAnalysisMethod ==2
    yLims = [-8 25];
linkaxes(hPlot3); ylim(hPlot3(1,1),[-8 25]); xlim(hPlot3(1,1),[0 100]);
end

for i=1:2
    for j=1:2
        set(hPlot3(i,j),'box','off','fontSize',fontSize)
        set(hPlot5(i,j),'box','off','fontSize',fontSize)
        xline(hPlot3(i,j),8,'k'); xline(hPlot3(i,j),12,'k')
        xline(hPlot3(i,j),freqRanges{2}(1)-1,'--r'); xline(hPlot3(i,j),freqRanges{2}(2)+1,'--r')
        xline(hPlot3(i,j),freqRanges{5}(1),'color',colors{3}); xline(hPlot3(i,j),freqRanges{5}(2),'color',colors{3})
        xline(hPlot3(i,j),freqRanges{6}(1),'m'); xline(hPlot3(i,j),freqRanges{6}(2),'m')
        xline(hPlot3(i,j),32,'c');
        yline(hPlot3(i,j),0,'--k','lineWidth',lineWidth)
    end
end



ylabel(hPlot2(1,1),{'Unipolar PSD' 'log_1_0 (power (\muV^2))' });
ylabel(hPlot2(2,1),{'Bipolar PSD' 'log_1_0 (power (\muV^2))' });
ylabel(hPlot3(1,1),{'Unipolar PSD' 'log_1_0 (power (\muV^2))' });
ylabel(hPlot3(2,1),{'Bipolar PSD' 'log_1_0 (power (\muV^2))' });

ylabel(hPlot4(1,1),{'Unipolar' '\Delta Power (dB)'});
ylabel(hPlot4(2,1),{'Bipolar' '\Delta Power (dB)'});
ylabel(hPlot5(1,1),{'Unipolar' '\Delta Power (dB)'});
ylabel(hPlot5(2,1),{'Bipolar' '\Delta Power (dB)'});

xlabel(hPlot2(2,1),'Frequency (Hz)');
xlabel(hPlot3(2,1),'Frequency (Hz)');


neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
neuralMeasuresLabels{2} = {'Gamma' [' (' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) ' Hz)']};
neuralMeasuresLabels{3} = {'Slow Gamma' [' (' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) ' Hz)']};
neuralMeasuresLabels{4} = {'Fast Gamma' [' (' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) ' Hz)']};
neuralMeasuresLabels{5} = {'SSVEP' '(32 Hz)'};

for i=1:5
annotation('textbox',[0.02 0.9-(i-1)*0.2 0.07 0.0252],'EdgeColor','none','HorizontalAlignment','center','String',neuralMeasuresLabels{i},'fontSize',14);
end  

for i= 1:5
    for j = 1:2
        set(hPlot1(i,j),'fontSize',fontSize)
    end
end

Datalabels = {'alpha','gamma','Slow-\gamma','Fast-\gamma'}; 
Datalabels2 = {'alpha','gamma','Slow-\gamma','Fast-\gamma','SSVEP'}; 
for i=1:2
    for j=1:2
        set(hPlot2(i,j),'XTickLabel',[],'YTick',[-4 0 4],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
        set(hPlot3(i,j),'XTickLabel',[],'YTick',[yLims(1) 0:5:yLims(2)],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
        set(hPlot4(i,j),'XTick',1:4,'XTickLabel',[],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
        set(hPlot5(i,j),'XTick',1:5,'XTickLabel',[],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
    end
end

set(hPlot2(2,1),'xTick',0:50:100,'XTickLabel',0:50:100);
set(hPlot3(2,1),'xTick',0:50:100,'XTickLabel',0:50:100);
set(hPlot4(2,1),'xTick',1:4,'xTickLabel',Datalabels,'XTickLabelRotation',30);
set(hPlot5(2,1),'xTick',1:5,'xTickLabel',Datalabels2,'XTickLabelRotation',30);


if SSVEPAnalysisMethod == 1
    ssvepMethod = 'SSVEP_SingleTrial';
elseif SSVEPAnalysisMethod == 2
    ssvepMethod = 'SSVEP_trialAvg';
end

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SF-Ori\');
figName = fullfile(saveFolder,['allSubjects_N_' num2str(length(subjectIdx)) '_' protocolType '_tapers_',num2str(tapers(2)) '_' ssvepMethod...
    '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz']);

saveas(hFig1,[figName '.fig'])
print(hFig1,[figName '.tif'],'-dtiff','-r600')


end