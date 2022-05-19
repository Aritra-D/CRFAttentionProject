function displayTopoPlots_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotRawTopoFlag,subjectIdx,eotCodeIdx,TFIdx,measureType,topoplot_style)

close all;
if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-1.000 0];
timingParamters.stRange = [0.250 1.250];
timingParamters.tgRange = [-1.000 0];
timingParamters.erpRange = [0 0.250];

freqRanges{1} = [8 12]; % alpha
freqRanges{2} = [20 66]; % gamma
freqRanges{3} = [24 24];  % SSVEP Left Stim
freqRanges{4} = [32 32];  % SSVEP Right Stim
numFreqs = length(freqRanges); %#ok<*NASGU>

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_tapers_' num2str(tapers(2)) '.mat']);
if exist(fileName, 'file')
    load(fileName,'energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [erpData,fftData,energyData,badHighPriorityElecs,badElecs] = ...
        getData_SRCLongProtocols_v1(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'erpData','fftData','energyData','badHighPriorityElecs','badElecs')
end

if analysisMethodFlag % Replacing the PSD and power Values for Flickering conditions when MT is computed on mean signal!
    %     clear energyData.dataBL energyData.dataST energyData.dataTG
    %     clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
    for iRef = 1:2
        energyData.dataBL{iRef}(:,:,:,:,2:3,:) = energyData.dataBL_trialAvg{iRef}(:,:,:,:,2:3,:);
        energyData.dataST{iRef}(:,:,:,:,2:3,:) = energyData.dataST_trialAvg{iRef}(:,:,:,:,2:3,:);
        energyData.dataTG{iRef}(:,:,:,:,2:3,:) = energyData.dataTG_trialAvg{iRef}(:,:,:,:,2:3,:);
        
        energyData.analysisDataBL{iRef}{1,3} = energyData.analysisDataBL_trialAvg{iRef}{1,3};
        energyData.analysisDataST{iRef}{1,3} = energyData.analysisDataST_trialAvg{iRef}{1,3};
        energyData.analysisDataTG{iRef}{1,3} = energyData.analysisDataTG_trialAvg{iRef}{1,3};
        energyData.analysisDataBL{iRef}{1,4} = energyData.analysisDataBL_trialAvg{iRef}{1,4};
        energyData.analysisDataST{iRef}{1,4} = energyData.analysisDataST_trialAvg{iRef}{1,4};
        energyData.analysisDataTG{iRef}{1,4} = energyData.analysisDataTG_trialAvg{iRef}{1,4};
    end
end


for iRef = 1:2
    for iAttLoc = 1:2
        for iRhythm = 1:2
            if plotRawTopoFlag
                if strcmp(measureType,'bandPower')
                    topoPower_ST{iRef}(iAttLoc,iRhythm,:) = squeeze(mean(log10(energyData.analysisDataST{iRef}{iRhythm}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1)); %#ok<*AGROW>
                    topoPower_TG{iRef}(iAttLoc,iRhythm,:) = squeeze(mean(log10(energyData.analysisDataTG{iRef}{iRhythm}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1));
                elseif strcmp(measureType,'SSVEP')
                    topoPower_ST{iRef}(iAttLoc,iRhythm,:) = squeeze(mean(log10(energyData.analysisDataST{iRef}{iRhythm+2}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1));
                    topoPower_TG{iRef}(iAttLoc,iRhythm,:) = squeeze(mean(log10(energyData.analysisDataTG{iRef}{iRhythm+2}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1));
                end
            else
                if strcmp(measureType,'bandPower')
                    topoPower_ST{iRef}(iAttLoc,iRhythm,:) = 10*(squeeze(mean(log10(energyData.analysisDataST{iRef}{iRhythm}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1))-squeeze(mean(log10(energyData.analysisDataBL{iRef}{iRhythm}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1)));
                    topoPower_TG{iRef}(iAttLoc,iRhythm,:) = 10*(squeeze(mean(log10(energyData.analysisDataTG{iRef}{iRhythm}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1))-squeeze(mean(log10(energyData.analysisDataBL{iRef}{iRhythm}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1)));
                elseif strcmp(measureType,'SSVEP')
                    topoPower_ST{iRef}(iAttLoc,iRhythm,:) = 10*(squeeze(mean(log10(energyData.analysisDataST{iRef}{iRhythm+2}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1))-squeeze(mean(log10(energyData.analysisDataBL{iRef}{iRhythm+2}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1)));
                    topoPower_TG{iRef}(iAttLoc,iRhythm,:) = 10*(squeeze(mean(log10(energyData.analysisDataTG{iRef}{iRhythm+2}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1))-squeeze(mean(log10(energyData.analysisDataBL{iRef}{iRhythm+2}(subjectIdx,:,eotCodeIdx,iAttLoc,TFIdx)),1)));
                end
            end
        end
    end
end


fontSizeLarge = 14; tickLengthMedium = [0.025 0];

showMode = 'dots';
showElecsUnipolarLeft = [24 29 57 61]; %[24 26 29 30 31 57 58 61 62 63];%[93 94 101 102 96 97 111 107 112];
showElecsUnipolarRight = [26 31 58 63];
showElecsBipolarLeft = [93 94 101];
showElecsBipolarRight = [96 97 102];

capLayout = {'actiCap64'};
% Get the electrode list
% clear cL bL chanlocs iElec electrodeList

cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat']));
chanlocs_Bipolar = cL_Bipolar.eloc;

hFig1 = figure(1); colormap magma
set(hFig1,'units','normalized','outerposition',[0 0 1 1])
[hPlotsTopo1,~,hPlotsTopoPos1] = getPlotHandles(2,2,[0.07 0.1 0.4 0.7],0.05,0.05,0); %#ok<*ASGLU>
[hPlotsTopo2,~,hPlotsTopoPos2] = getPlotHandles(2,2,[0.55 0.1 0.4 0.7],0.05,0.05,0);

hFig2 = figure(2); colormap magma
set(hFig2,'units','normalized','outerposition',[0 0 1 1])
[hPlotsTopo3,~,hPlotsTopoPos3] = getPlotHandles(2,2,[0.07 0.1 0.4 0.7],0.05,0.05,0);
[hPlotsTopo4,~,hPlotsTopoPos4] = getPlotHandles(2,2,[0.55 0.1 0.4 0.7],0.05,0.05,0);
if strcmp(measureType, 'bandPower')
    cLims1 = [-3 2];
    cLims2 = [-1 2];
elseif strcmp(measureType, 'SSVEP')
    cLims1 = [-5 10];
    cLims2 = [-5 10];
end

for iRef = 1:2
    for iAttLoc = 1:2
        for iRhythm = 1:2
            switch iRhythm
                case 1; cLimsTopo = cLims1;
                case 2; cLimsTopo = cLims2;
            end
            clear diffPowerST diffPowerTG
            
            diffPowerST = squeeze(topoPower_ST{iRef}(iAttLoc,iRhythm,:));
            diffPowerTG = squeeze(topoPower_TG{iRef}(iAttLoc,iRhythm,:));
            if iRef == 1
                figure(1); colormap magma
                if iAttLoc ==1
                    subplot(hPlotsTopo2(iRhythm,1)); cla; hold on;
                    topoplot_murty(diffPowerST,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerST); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarLeft);
                    
                    subplot(hPlotsTopo2(iRhythm,2)); cla; hold on;
                    topoplot_murty(diffPowerTG,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerTG); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarLeft);
                elseif iAttLoc ==2
                    subplot(hPlotsTopo1(iRhythm,1)); cla; hold on;
                    topoplot_murty(diffPowerST,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerST); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarRight);
                    
                    subplot(hPlotsTopo1(iRhythm,2)); cla; hold on;
                    topoplot_murty(diffPowerTG,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerTG); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarRight);
                end
            elseif iRef == 2
                figure(2); colormap magma
                if iAttLoc ==1
                    subplot(hPlotsTopo4(iRhythm,1)); cla; hold on;
                    topoplot_murty(diffPowerST,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerST); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsBipolarLeft);
                    
                    subplot(hPlotsTopo4(iRhythm,2)); cla; hold on;
                    topoplot_murty(diffPowerTG,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerTG); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsBipolarLeft);
                elseif iAttLoc ==2
                    subplot(hPlotsTopo3(iRhythm,1)); cla; hold on;
                    topoplot_murty(diffPowerST,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerST); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsBipolarRight);
                    
                    subplot(hPlotsTopo3(iRhythm,2)); cla; hold on;
                    topoplot_murty(diffPowerTG,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',diffPowerTG); caxis(cLimsTopo);
                    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsBipolarRight);
                end
            end
        end
    end
end

title(hPlotsTopo1(1,1),'Stimulus Onset');
title(hPlotsTopo1(1,2),'Pre-target');
title(hPlotsTopo2(1,1),'Stimulus Onset');
title(hPlotsTopo2(1,2),'Pre-target');

title(hPlotsTopo3(1,1),'Stimulus Onset');
title(hPlotsTopo3(1,2),'Pre-target');
title(hPlotsTopo4(1,1),'Stimulus Onset');
title(hPlotsTopo4(1,2),'Pre-target');

for i=1:2
    figure(i);
    textH1 = getPlotHandles(1,1,[0.23 0.9 0.01 0.01]);
    textH2 = getPlotHandles(1,1,[0.7 0.9 0.01 0.01]);
    textH3 = getPlotHandles(1,1,[0.05 0.53 0.01 0.01]);
    textH4 = getPlotHandles(1,1,[0.05 0.15 0.01 0.01]);
    textH5 = getPlotHandles(1,1,[0.27 0.97 0.01 0.01]);
    
    textString1 = 'Attend Left';
    textString2 = 'Attend Right';
    
    if strcmp(measureType,'bandPower')
        textString3 = 'Alpha (8-12 Hz)';
        textString4 = 'Gamma (20-66 Hz)';
    elseif strcmp(measureType,'SSVEP')
        textString3 = 'SSVEP (24 Hz)';
        textString4 = 'SSVEP (32 Hz)';
    end
    
    if eotCodeIdx==1
        eotString = 'Hits';
    elseif eotCodeIdx==2
        eotString = 'Misses';
    end
    
    if i==1
        if TFIdx == 1
            textString5 = [eotString ' - Unipolar Referencing Scheme - Cued: Static; Uncued: Static Stimuli'];
        elseif TFIdx == 2
            textString5 = [eotString ' - Unipolar Referencing Scheme - Cued: 12 Hz; Uncued: 16 Hz Stimuli'];
        elseif TFIdx == 3
            textString5 = [eotString ' - Unipolar Referencing Scheme - Cued: 16 Hz; Uncued: 12 Hz Stimuli'];
        end
    elseif i==2
        if TFIdx == 1
            textString5 = [eotString ' - Bipolar Referencing Scheme - Cued: Static; Uncued: Static Stimuli'];
        elseif TFIdx == 2
            textString5 = [eotString ' - Bipolar Referencing Scheme - Cued: 12 Hz; Uncued: 16 Hz Stimuli'];
        elseif TFIdx == 3
            textString5 = [eotString ' - Bipolar Referencing Scheme - Cued: 16 Hz; Uncued: 12 Hz Stimuli'];
        end
    end
    
    set(textH1,'Visible','Off'); set(textH2,'Visible','Off')
    set(textH3,'Visible','Off'); set(textH4,'Visible','Off');set(textH5,'Visible','Off');
    text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH1);
    text(0.35,1.15,textString2,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH2);
    text(0.35,1.15,textString3,'unit','normalized','fontsize',18,'fontweight','bold','rotation',90,'parent',textH3);
    text(0.35,1.15,textString4,'unit','normalized','fontsize',18,'fontweight','bold','rotation',90,'parent',textH4);
    text(0.35,1.15,textString5,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH5);
    
    
    cLimsTopo = cLims1;
    clims = cLimsTopo;
    clear cbData tmpPos hCB cbarAxis
    cbData = imread('colorbarMagma.png');
    tmpPos = get(hPlotsTopo1(1,2),'Position');
    hCB = subplot('Position',[tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.005 tmpPos(4)]);
    cbarAxis = clims(1):0.001:clims(2);
    imagesc([0 1],fliplr(cbarAxis),cbData);
    set(hCB,'ydir','normal','box','off');
    set(hCB,'xtick',[],'ytick',[ceil(clims(1)) 0 floor(clims(2))],'yticklabel',[ceil(clims(1)) 0 floor(clims(2))]);
    set(hCB,'yaxislocation','right');
    ylabel(hCB,'Power Change (dB)');
    set(hCB,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
    
    cLimsTopo = cLims2;
    clims = cLimsTopo;
    clear cbData tmpPos hCB cbarAxis
    cbData = imread('colorbarMagma.png');
    tmpPos = get(hPlotsTopo1(2,2),'Position');
    hCB = subplot('Position',[tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.005 tmpPos(4)]);
    cbarAxis = clims(1):0.001:clims(2);
    imagesc([0 1],fliplr(cbarAxis),cbData);
    set(hCB,'ydir','normal','box','off');
    set(hCB,'xtick',[],'ytick',[ceil(clims(1)) 0 floor(clims(2))],'yticklabel',[ceil(clims(1)) 0 floor(clims(2))]);
    set(hCB,'yaxislocation','right');
    ylabel(hCB,'Power Change (dB)');
    set(hCB,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
    
    cLimsTopo = cLims1;
    clims = cLimsTopo;
    clear cbData tmpPos hCB cbarAxis
    cbData = imread('colorbarMagma.png');
    tmpPos = get(hPlotsTopo2(1,2),'Position');
    hCB = subplot('Position',[tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.005 tmpPos(4)]);
    cbarAxis = clims(1):0.001:clims(2);
    imagesc([0 1],fliplr(cbarAxis),cbData);
    set(hCB,'ydir','normal','box','off');
    set(hCB,'xtick',[],'ytick',[ceil(clims(1)) 0 floor(clims(2))],'yticklabel',[ceil(clims(1)) 0 floor(clims(2))]);
    set(hCB,'yaxislocation','right');
    ylabel(hCB,'Power Change (dB)');
    set(hCB,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
    
    cLimsTopo = cLims2;
    clims = cLimsTopo;
    clear cbData tmpPos hCB cbarAxis
    cbData = imread('colorbarMagma.png');
    tmpPos = get(hPlotsTopo2(2,2),'Position');
    hCB = subplot('Position',[tmpPos(1)+tmpPos(3)+0.005 tmpPos(2) 0.005 tmpPos(4)]);
    cbarAxis = clims(1):0.001:clims(2);
    imagesc([0 1],fliplr(cbarAxis),cbData);
    set(hCB,'ydir','normal','box','off');
    set(hCB,'xtick',[],'ytick',[ceil(clims(1)) 0 floor(clims(2))],'yticklabel',[ceil(clims(1)) 0 floor(clims(2))]);
    set(hCB,'yaxislocation','right');
    ylabel(hCB,'Power Change (dB)');
    set(hCB,'fontsize',fontSizeLarge,'TickDir','out','TickLength',tickLengthMedium);
    
    
    if TFIdx == 1
        textStr = 'Cued_Static_Uncued_Static';
    elseif TFIdx == 2
        textStr = 'Cued_12Hz_Uncued_16Hz';
    elseif TFIdx == 3
        textStr = 'Cued_16Hz_Uncued_12Hz';
    end
    
    if i==1
        refType = 'Unipolar';
    elseif i==2
        refType = 'Bipolar';
    end
    
    if plotRawTopoFlag
        topoplotType = 'rawTopoPlot';
    else
        topoplotType = 'deltaTopoPlot';
    end
    

    
    % save Figures
    if length(subjectIdx) == 26
        figName = fullfile(folderSourceString,'topoplots-SRCLong',[protocolType '_' refType '_' eotString '_' measureType '_allSubjects_N_'  '_' num2str(length(subjectIdx)) '_analysisMethod',num2str(analysisMethodFlag) '_' topoplotType  '_EOTCode_' num2str(eotCodeIdx) '_tapers_' , num2str(tapers(2)) '_' textStr]);
    elseif length(subjectIdx)== 1
        figName = fullfile(folderSourceString,'topoplots-SRCLong',[protocolType '_' refType '_' eotString '_' measureType '_SubjectID_'      '_' num2str(subjectIdx)         '_analysisMethod',num2str(analysisMethodFlag) '_' topoplotType  '_EOTCode_' num2str(eotCodeIdx) '_tapers_' , num2str(tapers(2)) '_' textStr]);
    elseif length(subjectIdx)>1
        figName = fullfile(folderSourceString,'topoplots-SRCLong',[protocolType '_' refType '_' eotString '_' measureType '_SubjectIDs_'     '_' num2str(subjectIdx(1)) '_' num2str(subjectIdx(end)) '_analysisMethod', num2str(analysisMethodFlag) '_' topoplotType  '_EOTCode_' num2str(eotCodeIdx) '_tapers_' , num2str(tapers(2)) '_' textStr]);
        
        if i==1
            saveas(hFig1,[figName '.fig'])
            print(hFig1,[figName '.tif'],'-dtiff','-r600')
        elseif i==2
            saveas(hFig2,[figName '.fig'])
            print(hFig2,[figName '.tif'],'-dtiff','-r600')
        end
        
    end
end
end