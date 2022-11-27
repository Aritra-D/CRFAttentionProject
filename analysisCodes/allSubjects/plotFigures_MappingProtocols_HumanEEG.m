function plotFigures_MappingProtocols_HumanEEG(protocolType2,...
    SSVEPAnalysisMethod,removeBadElectrodeData,subjectIdx,plotConsolidatedResultsFlag,topoplot_style,badTrialStr)

close all;

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParameters.blRange = [-0.5 0];
timingParameters.stRange = [0.25 0.75];
timingParameters.erpRange = [0 0.25];

freqRanges{1} = [8 12];    % alpha
freqRanges{2} = [25 70];   % gamma
freqRanges{3} = [24 24];   % SSVEP Left Stim
freqRanges{4} = [32 32];   % SSVEP Right Stim
freqRanges{5} = [26 34];   % Slow Gamma
freqRanges{6} = [44 56];   % Fast Gamma
freqRanges{7} = [102 250]; % High Gamma

numFreqs = length(freqRanges); %#ok<*NASGU>

% Plotting
% Display Properties
if plotConsolidatedResultsFlag
    hFig = figure(1);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlot1 = getPlotHandles(4,5,[0.07 0.1 0.65 0.85],0.01,0.03,1); % Topoplots for alpha
    hPlot2 = getPlotHandles(3,1,[0.78 0.1 0.2 0.85],0.04,0.06,1);
    colorAxis_ssvep{1} = [-1 3];
    colorAxis_ssvep{2} = [-1 10];
else
    hFig = figure(1);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlot1 = getPlotHandles(5,4,[0.07 0.1 0.47 0.85],0.01,0.03,1); % Topoplots for alpha
    hPlot2 = getPlotHandles(3,3,[0.59 0.1 0.4 0.85],0.04,0.06,1);
end

plotSFOriData(hPlot1,subjectIdx,folderSourceString,timingParameters,freqRanges,tapers,removeBadElectrodeData,topoplot_style,badTrialStr)
removeBadEyeTrialsFlag = 0;
fileName2 = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',...
    [protocolType2 '_tapers_' num2str(tapers(2)) '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz_' 'badTrial_' badTrialStr '_removeBadEyeTrialsFlag_' num2str(removeBadEyeTrialsFlag) '.mat']);


fileName3 = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',...
    ['SFOri-Summary_tapers_' num2str(tapers(2)) '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz_' 'badTrial_' badTrialStr '_removeBadEyeTrialsFlag_' num2str(removeBadEyeTrialsFlag) '.mat']);

if exist(fileName2, 'file')
    load(fileName2,'energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
    if exist(fileName3, 'file')
        load(fileName3)
        SFOriDataFlag =1;
    else
        SFOriDataFlag =1;
        disp('SF-Ori data not Found!')
    end
else
    [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = ...
        getData_MappingProtocols(protocolType2,gridType,timingParameters,tapers,freqRanges,badTrialStr,removeBadEyeTrialsFlag);
    save(fileName2,'fftData','energyData','energyDataTF','freqRanges','badHighPriorityElecs','badElecs')
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iProt = 1:4
            for iRef = 1:2
                clear badElecsTMP
                badElecsTMP = badElecs{iRef}{subjectIdx(iSub),iProt};
                
                if exist('erpData','var')
                    % removing ERP data for Bad Electrodes
                    erpData.dataBL{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                    erpData.dataST{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                    erpData.analysisData_BL{iRef}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                    erpData.analysisData_ST{iRef}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                end
                
                % removing Energy data (PSD & Power) for Bad Electrodes
                energyData.dataBL{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                energyData.dataST{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                
                for iFreqRanges = 1: length(freqRanges)
                    energyData.analysisDataBL{iRef}{iFreqRanges}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                    energyData.analysisDataST{iRef}{iFreqRanges}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                end
            end
        end
    end
end

nanFlag = 'omitnan';

% Cap Layout & Ref Scheme related Info
capLayout = {'actiCap64'};
cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

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

colorAxis_alpha = [-2 2];
colorAxis_gamma = [-1 1.5];

colormap(jet);

if plotConsolidatedResultsFlag
    
    % Main Loop for Topoplots
    for i= 1:4 % Neural Measures 1:Alpha, 2: Gamma (25-70 Hz), 3: SSVEP (24-32 Hz Combined)-SingleTrialEstimate; 4: SSVEP (12-16 Hz Combined)-TrialAvgEstimate
        for j= 1:4 % 1: Eccentricity 2 deg, 2: Ecc 4 deg, 3: Ecc 6 deg, 4: Ecc 8 deg
            clear BLpower STPower topoPlotDataTMP
            switch i
                case 1
                    neuralMeasure = 1; refType = 1; TF = 1;
                    BLPower = squeeze(energyData.analysisDataBL{1,refType}{1,neuralMeasure}(:,j,TF,:));
                    STPower = squeeze(energyData.analysisDataST{1,refType}{1,neuralMeasure}(:,j,TF,:));
                    colorRange = colorAxis_alpha; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
                case 2
                    neuralMeasure = 2; refType = 1; TF = 1;
                    BLPower = squeeze(energyData.analysisDataBL{1,refType}{1,neuralMeasure}(:,j,TF,:));
                    STPower = squeeze(energyData.analysisDataST{1,refType}{1,neuralMeasure}(:,j,TF,:));
                    colorRange = colorAxis_gamma; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
                case 3
                    neuralMeasures = [3 4]; refType = 1; TF = 2;
                    for k=1:length(neuralMeasures)
                        switch k
                            case 1
                                BLPowerTMP(k,:,:) = squeeze(energyData.analysisDataBL{1,refType}{1,neuralMeasures(k)}(:,j,TF,:));
                                STPowerTMP(k,:,:) = squeeze(energyData.analysisDataST{1,refType}{1,neuralMeasures(k)}(:,j,TF,:));
                            case 2
                                BLPowerTMP(k,:,:) = mirrorTopoplotData(squeeze(energyData.analysisDataBL{1,refType}{1,neuralMeasures(k)}(:,j,TF,:))); %#ok<*AGROW>
                                STPowerTMP(k,:,:) = mirrorTopoplotData(squeeze(energyData.analysisDataST{1,refType}{1,neuralMeasures(k)}(:,j,TF,:)));
                        end
                    end
                    BLPower = squeeze(mean(BLPowerTMP,1));
                    STPower = squeeze(mean(STPowerTMP,1));
                    colorRange = colorAxis_ssvep{1}; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
                case 4
                    neuralMeasures = [3 4]; refType = 1; TF = 2;
                    for k=1:length(neuralMeasures)
                        switch k
                            case 1
                                BLPowerTMP(k,:,:) = squeeze(energyData.analysisDataBL_trialAvg{1,refType}{1,neuralMeasures(k)}(:,j,TF,:));
                                STPowerTMP(k,:,:) = squeeze(energyData.analysisDataST_trialAvg{1,refType}{1,neuralMeasures(k)}(:,j,TF,:));
                            case 2
                                BLPowerTMP(k,:,:) = mirrorTopoplotData(squeeze(energyData.analysisDataBL_trialAvg{1,refType}{1,neuralMeasures(k)}(:,j,TF,:))); %#ok<*AGROW>
                                STPowerTMP(k,:,:) = mirrorTopoplotData(squeeze(energyData.analysisDataST_trialAvg{1,refType}{1,neuralMeasures(k)}(:,j,TF,:)));
                        end
                    end
                    BLPower = squeeze(mean(BLPowerTMP,1));
                    STPower = squeeze(mean(STPowerTMP,1));
                    colorRange = colorAxis_ssvep{2}; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
            end
            topoPlotDataTMP = 10*(squeeze(mean(log10(STPower),1,nanFlag)) - squeeze(mean(log10(BLPower),1,nanFlag)));
            subplot(hPlot1(i,j+1)); cla; hold on;
            topoplot_murty(topoPlotDataTMP,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataTMP);
            caxis(colorRange);cTicks = [colorRange(1) 0 colorRange(2)]; cBar = colorbar;
            tickPlotLength = get(hPlot2(1,1),'TickLength'); fontSize = 12;
            set(cBar,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
            if i==4 && j==4
                cBar.Label.String ='\Delta Power (dB)'; cBar.Label.FontSize = 14;
            end
            
            topoplot_murty([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecs);
        end
    end
    
    colors = {'k','r','c'};
    
    if SFOriDataFlag
        stimList = 0:2:8;
        xTickLabels = {'FS','2','4','6','8'};
        
    else
        stimList = 2:2:8;
        xTickLabels = {'2','4','6','8'};
    end
    
    % Main Loop for delta Power
    for i= 1:4 % Neural Measures 1:Alpha, 2: Gamma (25-70 Hz), 3: SSVEP
        switch i
            case 1; elecs = elecUnipolarList; neuralMeasure = 1;  refType = 1; TF = 1; hPlot = hPlot2(1,1); markerStyle = '-o'; color = colors{neuralMeasure};
                BLPower = squeeze(mean(energyData.analysisDataBL{1,refType}{1,neuralMeasure}(:,:,TF,elecs),4,nanFlag));
                STPower = squeeze(mean(energyData.analysisDataST{1,refType}{1,neuralMeasure}(:,:,TF,elecs),4,nanFlag));
                
            case 2; elecs = elecUnipolarList; neuralMeasure = 2;  refType = 1; TF = 1; hPlot = hPlot2(2,1); markerStyle = '-o'; color = colors{neuralMeasure};
                BLPower = squeeze(mean(energyData.analysisDataBL{1,refType}{1,neuralMeasure}(:,:,TF,elecs),4,nanFlag));
                STPower = squeeze(mean(energyData.analysisDataST{1,refType}{1,neuralMeasure}(:,:,TF,elecs),4,nanFlag));
                
            case 3; neuralMeasures = [3 4]; refType = 1; TF = 2; hPlot = hPlot2(3,1); markerStyle = '-o'; color = colors{neuralMeasures(1)};
                for k=1:length(neuralMeasures)
                    switch k
                        case 1; elecs = elecList_Unipolar_Left;
                            clear BLPowerTMP STPowerTMP
                            BLPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataBL{1,refType}{1,neuralMeasures(2)}(:,:,TF,elecs));
                            STPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataST{1,refType}{1,neuralMeasures(2)}(:,:,TF,elecs));
                        case 2; elecs = elecList_Unipolar_Right;
                            BLPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataBL{1,refType}{1,neuralMeasures(1)}(:,:,TF,elecs));
                            STPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataST{1,refType}{1,neuralMeasures(1)}(:,:,TF,elecs));
                    end
                end
                
                BLPower = squeeze(mean(cat(3,squeeze(BLPowerTMP(1,:,:,:)),squeeze(BLPowerTMP(2,:,:,:))),3,nanFlag));
                STPower = squeeze(mean(cat(3,squeeze(STPowerTMP(1,:,:,:)),squeeze(STPowerTMP(2,:,:,:))),3,nanFlag));
                
            case 4; neuralMeasures = [3 4]; refType = 1; TF = 2; hPlot = hPlot2(3,1); markerStyle = '--o'; color = colors{neuralMeasures(1)};
                for k=1:length(neuralMeasures)
                    switch k
                        case 1; elecs = elecList_Unipolar_Left;
                            BLPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataBL_trialAvg{1,refType}{1,neuralMeasures(2)}(:,:,TF,elecs));
                            STPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataST_trialAvg{1,refType}{1,neuralMeasures(2)}(:,:,TF,elecs));
                        case 2; elecs = elecList_Unipolar_Right;
                            BLPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataBL_trialAvg{1,refType}{1,neuralMeasures(1)}(:,:,TF,elecs));
                            STPowerTMP(k,:,:,:) = squeeze(energyData.analysisDataST_trialAvg{1,refType}{1,neuralMeasures(1)}(:,:,TF,elecs));
                    end
                end
                
                BLPower = squeeze(mean(cat(3,squeeze(BLPowerTMP(1,:,:,:)),squeeze(BLPowerTMP(2,:,:,:))),3,nanFlag));
                STPower = squeeze(mean(cat(3,squeeze(STPowerTMP(1,:,:,:)),squeeze(STPowerTMP(2,:,:,:))),3,nanFlag));
        end
        
        
        deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
        mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
        semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
        
        if SFOriDataFlag
            mDeltapower = [mean_deltaPower_FS_MappingGroup(i) mDeltapower];
            semPower = [sem_deltaPower_FS_MappingGroup(i) semPower];
        end
        
        errorbar(hPlot,stimList,mDeltapower,semPower,...
            markerStyle,'color',color,'MarkerSize',10,'MarkerEdgeColor',...
            color,'MarkerFaceColor',color,...
            'LineWidth',1.5); hold(hPlot, 'on');
        
%         if SFOriDataFlag
%             color = 'g';
%             errorbar(hPlot,stimList(1),mean_deltaPower_FS_allGroups(i), sem_deltaPower_FS_allGroups(i),...
%                 'o','color',color,'MarkerSize',10,'MarkerEdgeColor',...
%                 color,'MarkerFaceColor',color,...
%                 'LineWidth',1.5); hold(hPlot, 'on');
%             color = 'b';
%             errorbar(hPlot,stimList(1),mean_deltaPower_FS_AttentionGroup(i), sem_deltaPower_FS_AttentionGroup(i),...
%                 'o','color',color,'MarkerSize',10,'MarkerEdgeColor',...
%                 color,'MarkerFaceColor',color,...
%                 'LineWidth',1.5); hold(hPlot, 'on');
%         end
    end
    
    fontSize = 12;
    tickLength = 2*get(hPlot2(1,1),'TickLength');
    set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',12,'Xlim',[-2 10])
    set(hPlot2(1,1),'xTick',stimList(1):2:stimList(end),'yTick',[-4 -2 0],'xTickLabel',[],'XTickLabelRotation',0)
    set(hPlot2(2,1),'xTick',stimList(1):2:stimList(end),'yTick',[-1 0 1 2],'xTickLabel',[],'XTickLabelRotation',0)
    set(hPlot2(3,1),'xTick',stimList(1):2:stimList(end),'yTick',[-2 0:10:20],'xTickLabel',xTickLabels,'XTickLabelRotation',0)
    set(hPlot2(1,1),'YDir','reverse')
    
    ylim(hPlot2(1,1),[-4 0]);
    ylim(hPlot2(2,1),[-1 2]);
    ylim(hPlot2(3,1),[-2 20]);

    yline(hPlot2(2,1),0,'--k','LineWidth',1.2);
    yline(hPlot2(3,1),0,'--k','LineWidth',1.2);
    yline(hPlot2(1,1),-2,'--k','LineWidth',1.2);

    
    xlabel(hPlot2(3,1),'azi/ele/diam (degree)')
    ylabel(hPlot2(3,1),'Change in Power (dB)')
    
    title(hPlot2(1,1),'alpha (8-12 Hz)');
    title(hPlot2(2,1),'Gamma (25-70 Hz)');
    title(hPlot2(3,1),'SSVEP');
   
    neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
    neuralMeasuresLabels{2} = {'Gamma' '(25-70 Hz)'};
    neuralMeasuresLabels{3} = {'SSVEP' 'Single Trial Estimate' };
    neuralMeasuresLabels{4} = {'SSVEP' 'Trial Avg Estimate' };
    
    for i=1:4
        annotation('textbox',[0.0 0.86-(i-1)*0.22 0.07 0.0252],'EdgeColor','none','HorizontalAlignment','center','String',neuralMeasuresLabels{i},'fontSize',14);
    end
    
    for i= 1:4
        for j = 1:4
            set(hPlot1(i,j),'fontSize',12,'tickLength',2*tickLength,'TickDir','out')
        end
    end
    
    
    
    fontSize = 14;
    strList = {'FS','2 ','4 ','6 ','8 '};
    for j=1:5
        if j==1
            title(hPlot1(1,j),[strList{j}],'fontSize', fontSize)
        else
            title(hPlot1(1,j),[strList{j} char(176)],'fontSize', fontSize)
        end
    end
    
    annotation('textbox',[0.0 0.92 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','A','fontWeight','bold','fontSize',28);
    annotation('textbox',[0.69 0.92 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','B','fontWeight','bold','fontSize',28);
    annotation('textbox',[0.69 0.61 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','C','fontWeight','bold','fontSize',28);
    annotation('textbox',[0.69 0.32 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','D','fontWeight','bold','fontSize',28);
    
    
    
else
    
    if SSVEPAnalysisMethod == 1
        colorAxis_ssvep = [-1 3];
    elseif SSVEPAnalysisMethod == 2
        colorAxis_ssvep = [-1 10];
    end
    
    % Shift to power computed
    if SSVEPAnalysisMethod == 2
        for iRef =1:2
            energyData.analysisDataBL{iRef}(1,3) = energyData.analysisDataBL_trialAvg{iRef}(1,3);
            energyData.analysisDataST{iRef}(1,3) = energyData.analysisDataST_trialAvg{iRef}(1,3);
            energyData.analysisDataBL{iRef}(1,4) = energyData.analysisDataBL_trialAvg{iRef}(1,4);
            energyData.analysisDataST{iRef}(1,4) = energyData.analysisDataST_trialAvg{iRef}(1,4);
        end
    end
    
    neuralMeasures = [1 5 6 3 4]; % Neural Measures 1:Alpha, 2: Slow Gamma, 3: Fast Gamma, 4: SSVEP 24 Hz; 4: SSVEP 32 Hz;
    
    % Main Loop for Topoplots
    for i= 1:5 % Neural Measures 1:Alpha, 2: Slow Gamma, 3: Fast Gamma, 4: SSVEP 24 Hz; 4: SSVEP 32 Hz;
        for j= 1:4 % 1: Eccentricity 2 deg, 2: Ecc 4 deg, 3: Ecc 6 deg, 4: Ecc 8 deg
            clear BLpower STPower topoPlotDataTMP
            if i== 1
                BLPower = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(i)}(:,j,1,:));
                STPower = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(i)}(:,j,1,:));
                colorRange = colorAxis_alpha; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
            elseif i==2 || i==3
                BLPower = squeeze(energyData.analysisDataBL{1,2}{1,neuralMeasures(i)}(:,j,1,:));
                STPower = squeeze(energyData.analysisDataST{1,2}{1,neuralMeasures(i)}(:,j,1,:));
                colorRange = colorAxis_gamma; chanLocs = chanlocs_Bipolar; showElecs = elecBipolarList;
            elseif i==4 || i==5
                BLPower = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(i)}(:,j,2,:));
                STPower = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(i)}(:,j,2,:));
                colorRange = colorAxis_ssvep; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
            end
            topoPlotDataTMP = 10*(squeeze(mean(log10(STPower),1,nanFlag)) - squeeze(mean(log10(BLPower),1,nanFlag)));
            subplot(hPlot1(i,j)); cla; hold on;
            topoplot_murty(topoPlotDataTMP,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataTMP); caxis(colorRange);colorbar;
            topoplot_murty([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecs);
        end
    end
    
    fontSize = 14;
    strList = {'FS','2 ','4 ','6 ','8 '};
    for j=1:5
        if j==1
            title(hPlot1(1,j),[strList{j}],'fontSize', fontSize)
        else
            title(hPlot1(1,j),[strList{j} char(176)],'fontSize', fontSize)
        end
    end
    
    neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
    neuralMeasuresLabels{2} = {'Slow Gamma' '(20-34 Hz)'};
    neuralMeasuresLabels{3} = {'Fast Gamma' '(36-66 Hz)'};
    neuralMeasuresLabels{4} = {'SSVEP' '(24 Hz)'};
    neuralMeasuresLabels{5} = {'SSVEP' '(32 Hz)'};
    
    stimList = 2:2:8;
    colors = {'k',[0.4940 0.1840 0.5560],'m','g','c'};
    
    % Main Loop for delta power plots for different Neural measures
    
    for iNeuralMeasure = 1:5
        for iPlot = 1:3
            clear BLpower STPower deltaPower
            if iNeuralMeasure== 1
                switch iPlot
                    case 1; elecs = elecList_Unipolar_Left;
                    case 2; elecs = elecList_Unipolar_Right;
                    case 3; elecs = elecUnipolarList;
                end
                BLPower = squeeze(mean(energyData.analysisDataBL{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
                STPower = squeeze(mean(energyData.analysisDataST{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
                
                deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                
                errorbar(hPlot2(iNeuralMeasure,iPlot),stimList,mDeltapower,semPower,...
                    '-o','color',colors{1},'MarkerSize',10,'MarkerEdgeColor',...
                    colors{1},'MarkerFaceColor',colors{1},...
                    'LineWidth',1.5);
                
            elseif iNeuralMeasure == 2 || iNeuralMeasure == 3
                switch iPlot
                    case 1; elecs = elecList_Bipolar_Left;
                    case 2; elecs = elecList_Bipolar_Right;
                    case 3; elecs = elecBipolarList;
                end
                BLPower = squeeze(mean(energyData.analysisDataBL{1,2}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
                STPower = squeeze(mean(energyData.analysisDataST{1,2}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
                
                deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                
                
                errorbar(hPlot2(2,iPlot),stimList,mDeltapower,semPower,...
                    '-o','color',colors{iNeuralMeasure},'MarkerSize',10,'MarkerEdgeColor',...
                    colors{iNeuralMeasure},'MarkerFaceColor',colors{iNeuralMeasure},...
                    'LineWidth',1.5); hold (hPlot2(2,iPlot),'on');
                
                
            elseif iNeuralMeasure == 4 || iNeuralMeasure == 5
                
                if iNeuralMeasure == 4 && iPlot == 1
                    elecs = elecList_Unipolar_Right;
                    BLPower = squeeze(mean(energyData.analysisDataBL{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                    STPower = squeeze(mean(energyData.analysisDataST{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                    deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                    mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                    semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                    
                    errorbar(hPlot2(3,1),stimList,mDeltapower,semPower,...
                        '-o','color',colors{4},'MarkerSize',10,'MarkerEdgeColor',...
                        colors{4},'MarkerFaceColor',colors{4},...
                        'LineWidth',1.5); hold on;
                    
                elseif iNeuralMeasure == 5 && iPlot == 2
                    elecs = elecList_Unipolar_Left;
                    BLPower = squeeze(mean(energyData.analysisDataBL{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                    STPower = squeeze(mean(energyData.analysisDataST{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                    deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                    mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                    semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                    errorbar(hPlot2(3,2),stimList,mDeltapower,semPower,...
                        '-o','color',colors{5},'MarkerSize',10,'MarkerEdgeColor',...
                        colors{5},'MarkerFaceColor',colors{5},...
                        'LineWidth',1.5); hold on;
                    
                elseif iNeuralMeasure == 5 && iPlot == 3
                    elecs = elecList_Unipolar_Left;
                    BLPower_Left = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(5)}(:,:,2,elecs));
                    STPower_Left = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(5)}(:,:,2,elecs));
                    
                    elecs = elecList_Unipolar_Right;
                    BLPower_Right = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(4)}(:,:,2,elecs));
                    STPower_Right = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(4)}(:,:,2,elecs));
                    
                    BLPower_combined = cat(3,BLPower_Left,BLPower_Right);
                    STPower_combined = cat(3,STPower_Left,STPower_Right);
                    
                    BLPower = squeeze(mean(BLPower_combined,3,nanFlag));
                    STPower = squeeze(mean(STPower_combined,3,nanFlag));
                    
                    deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                    mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                    semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                    errorbar(hPlot2(3,3),stimList,mDeltapower,semPower,...
                        '--o','color',colors{5},'MarkerSize',10,'MarkerEdgeColor',...
                        colors{5},'MarkerFaceColor',colors{5},...
                        'LineWidth',1.5); hold on;
                end
            end
        end
    end
    
    
    tickLength = 2*get(hPlot2(1,1),'TickLength');
    xTickLabels = {'2','4','6','8'};
    set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,...
        'fontSize',12,'Xlim',[0 10],'xTick',2:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)
    
    linkaxes(hPlot2(1,:)); ylim(hPlot2(1,1),[-4 0]);
    linkaxes(hPlot2(2,:)); ylim(hPlot2(2,1),[-1.5 0.5]);
    linkaxes(hPlot2(3,:)); ylim(hPlot2(3,1),[-2 10]);
    
    xlabel(hPlot2(3,1),'azi/ele/diam (degree)')
    ylabel(hPlot2(3,1),'Change in Power (dB)')
    
    title(hPlot2(1,1),'Left Elecs');
    title(hPlot2(1,2),'Right Elecs');
    title(hPlot2(1,3),'Combined');
    
    neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
    neuralMeasuresLabels{2} = {'Slow Gamma' '(20-34 Hz)'};
    neuralMeasuresLabels{3} = {'Fast Gamma' '(36-66 Hz)'};
    neuralMeasuresLabels{4} = {'SSVEP' '(24 Hz)'};
    neuralMeasuresLabels{5} = {'SSVEP' '(32 Hz)'};
    
    for i=1:5
        annotation('textbox',[0.0 0.88-(i-1)*0.18 0.07 0.0252],'EdgeColor','none','HorizontalAlignment','center','String',neuralMeasuresLabels{i},'fontSize',12);
    end
    
    for i= 1:5
        for j = 1:4
            set(hPlot1(i,j),'fontSize',12,'tickLength',2*tickLength,'TickDir','out')
        end
    end
    
end


if SSVEPAnalysisMethod == 1
    ssvepMethod = 'SSVEP_SingleTrial';
elseif SSVEPAnalysisMethod == 2
    ssvepMethod = 'SSVEP_trialAvg';
end

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\Mapping\');

figName = fullfile(saveFolder,['allSubjects_N_' num2str(length(subjectIdx))...
    '_' protocolType2 '_tapers_',num2str(tapers(2)) '_' ssvepMethod...
    '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz_' 'badTrial_' badTrialStr]);
saveas(hFig,[figName 'v3.fig'])
print(hFig,[figName 'v3.tif'],'-dtiff','-r600')

end

% Accessory Functions
function plotSFOriData(hPlot1,subjectIdx,folderSourceString,timingParameters,freqRanges,tapers,removeBadElectrodeData,topoplot_style,badTrialStr)
protocolType1 = 'SFOri-MappingGroup'; gridType = 'EEG';
removeBadEyeTrialsFlag =0;
fileName1 = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',...
    [protocolType1 '_tapers_' num2str(tapers(2)) ...
    '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz_v2_' 'badTrial_' badTrialStr '_removeBadEyeTrialsFlag_' num2str(removeBadEyeTrialsFlag) '.mat']);


if exist(fileName1, 'file')
    load(fileName1,'energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = ...
        getData_SFORIProtocols(protocolType1,gridType,timingParameters,tapers,freqRanges,badTrialStr,removeBadEyeTrialsFlag);
    save(fileName1,'fftData','energyData','energyDataTF','freqRanges','badHighPriorityElecs','badElecs')
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

neuralMeasures = [1 2 3 4]; % Neural Measures 1:Alpha, 2: Gamma, 3: SSVEP 32 Hz Single Trial, 4: SSVEP 32 Hz Trial Avg;
colormap(jet);
colorAxis_alpha = [-2 2];
colorAxis_gamma = [-1 1.5];
nanFlag = 'omitnan';

% compute power only for  max Gamma SF-Ori condition

BLPower{1} = squeeze(energyData.analysisDataBL_maxGamma{1,1}{1,1}(:,1,:));
BLPower{2} = squeeze(energyData.analysisDataBL_maxGamma{1,1}{1,2}(:,1,:));
BLPower{3} = squeeze(energyData.analysisDataBL_maxGamma{1,1}{1,4}(:,2,:));
BLPower{4} = squeeze(energyData.analysisDataBL_trialAvg_maxGamma{1,1}{1,4}(:,2,:));

STPower{1} = squeeze(energyData.analysisDataST_maxGamma{1,1}{1,1}(:,1,:));
STPower{2} = squeeze(energyData.analysisDataST_maxGamma{1,1}{1,2}(:,1,:));
STPower{3} = squeeze(energyData.analysisDataST_maxGamma{1,1}{1,4}(:,2,:));
STPower{4} = squeeze(energyData.analysisDataST_trialAvg_maxGamma{1,1}{1,4}(:,2,:));

for j = 1: length(neuralMeasures) % 1- alpha, 2- gamma, 3- slow gamma, 4- fast gamma, 5- SSVEP
    if j==1
        colorRange = colorAxis_alpha; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
    elseif j==2
        colorRange = colorAxis_gamma; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
    elseif j==3
        colorRange = [-1 10]; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
    elseif j==4
        colorRange = [-1 20]; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
    end
    
    topoPlotDataTMP = 10*(squeeze(mean(log10(STPower{j}),1,nanFlag)) - squeeze(mean(log10(BLPower{j}),1,nanFlag)));
    subplot(hPlot1(j,1)); cla; hold on;
    topoplot_murty(topoPlotDataTMP,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataTMP);
    caxis(colorRange); cTicks = [colorRange(1) 0 colorRange(2)]; cBar = colorbar;
    tickPlotLength = get(hPlot1(1,1),'TickLength'); fontSize = 12;
    set(cBar,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
    topoplot_murty([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecs);
end
end


function mirrored_topoData = mirrorTopoplotData(data)
mirror_elecNums = [2 1	7	6	5	4	3	11	10	9	8	16	15	14 ...
    13	12	22	21	20	19	18	17	27	26	25	24	23	32	31	30	29 ...
    28	36	35	34	33	40	39	38	37	46	45	44	43	42	41	50	49 ...
    48	47	55	54	53	52	51	59	58	57	56	64	63	62	61	60];

mirrored_topoData = data(:,mirror_elecNums);


% for i = 1:size(data,1)
%         mirrored_topoData2(i,:) = data(i,mirror_elecNums);
% end
%
% for i = 1:size(data,1)
%     for j = 1:size(data,2)
%         mirrored_topoData(i,j) = data(i,mirror_elecNums(j));
%     end
% end

end

