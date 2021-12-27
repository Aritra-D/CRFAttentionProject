function plotFigures_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotPSDFlag,plotDeltaPSDFlag,subjectIdx,eotCodeIdx)

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
freqRanges{3} = [23 23];  % SSVEP Left Stim
freqRanges{4} = [31 31];  % SSVEP Right Stim
numFreqs = length(freqRanges); %#ok<*NASGU>

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_tapers_' num2str(tapers(2)) 'new.mat']);
if exist(fileName, 'file')
    load(fileName) %#ok<*LOAD>
else
    [erpData,fftData,energyData,badHighPriorityElecs,badElecs] = ...
        getData_SRCLongProtocols(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'erpData','fftData','energyData','badHighPriorityElecs','badElecs')
end

% Plotting
attendColors = {'r', 'b'}; % r = Attend contralateral; b = Attend ipsilateral

% Electrode List
electrodeList_Unipolar = getElectrodeList('actiCap64','unipolar',1);
electrodeList_Bipolar = getElectrodeList('actiCap64','bipolar',1);

highPriorityUnipolarElectrodes = getHighPriorityElectrodes('actiCap64');
highPriorityBipolarElectrodes = [93 94 101 102 96 97 111 107 112];

elecList_Unipolar_Left = [24 29 57 61];
elecList_Unipolar_Right = [26 31 58 63];

elecList_Bipolar_Left = [93 94 101];
elecList_Bipolar_Right = [96 97 102];

elecList_Left{1} = elecList_Unipolar_Left; elecList_Left{2} = elecList_Bipolar_Left;
elecList_Right{1} = elecList_Unipolar_Right; elecList_Right{2} = elecList_Bipolar_Right;

if analysisMethodFlag
    
    clear energyData.dataBL energyData.dataST energyData.dataTG
    clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
    energyData.dataBL = energyData.dataBL_trialAvg;
    energyData.dataST = energyData.dataST_trialAvg;
    energyData.dataTG = energyData.dataTG_trialAvg;
    
    energyData.analysisDataBL = energyData.analysisDataBL_trialAvg;
    energyData.analysisDataST = energyData.analysisDataST_trialAvg;
    energyData.analysisDataBL = energyData.analysisDataTG_trialAvg;
    
end

% Combining datasets for Attend Contralateral vs Attend Ipsilateral
% Conditions

% contralateralERP_ST = cell(1,2); contralateralERP_TG = cell(1,2);
% contralateralRMSVals_ERP_BL = cell(1,2); contralateralRMSVals_ERP_ST = cell(1,2); contralateralRMSVals_ERP_TG = cell(1,2);

contralateralERP_ST=cell(1,2); contralateralERP_TG = cell(1,2);
ipsilateralERP_ST=cell(1,2);ipsilateralERP_TG=cell(1,2);
contralateralRMSValsBL =cell(1,2); contralateralRMSValsST =cell(1,2);contralateralRMSValsTG=cell(1,2);
ipsilateralRMSValsBL =cell(1,2); ipsilateralRMSValsST =cell(1,2);ipsilateralRMSValsTG=cell(1,2);

contralateralPSDBL = cell(1,2); contralateralPSDST = cell(1,2); contralateralPSDTG = cell(1,2);
ipsilateralPSDBL = cell(1,2); ipsilateralPSDST = cell(1,2); ipsilateralPSDTG = cell(1,2);
commonPSDBL = cell(1,2);

contralateralPowerValsBL = cell(1,2); contralateralPowerValsST = cell(1,2); contralateralPowerValsTG = cell(1,2);
ipsilateralPowerValsBL = cell(1,2); ipsilateralPowerValsST = cell(1,2); ipsilateralPowerValsTG = cell(1,2);


for iRef =1:2
    contralateralERP_ST{iRef} = cat(2,erpData.dataST{iRef}(:,elecList_Left{iRef},:,1,:,:),erpData.dataST{iRef}(:,elecList_Right{iRef},:,2,:,:));
    contralateralERP_TG{iRef} = cat(2,erpData.dataTG{iRef}(:,elecList_Left{iRef},:,1,:,:),erpData.dataTG{iRef}(:,elecList_Right{iRef},:,2,:,:));
    
    ipsilateralERP_ST{iRef} = cat(2,erpData.dataST{iRef}(:,elecList_Right{iRef},:,1,:,:),erpData.dataST{iRef}(:,elecList_Left{iRef},:,2,:,:));
    ipsilateralERP_TG{iRef} = cat(2,erpData.dataTG{iRef}(:,elecList_Right{iRef},:,1,:,:),erpData.dataTG{iRef}(:,elecList_Left{iRef},:,2,:,:));
    
    contralateralRMSValsBL{iRef} = cat(2,erpData.analysisData_BL{iRef}(:,elecList_Left{iRef},:,1,:),erpData.analysisData_BL{iRef}(:,elecList_Right{iRef},:,2,:));
    contralateralRMSValsST{iRef} = cat(2,erpData.analysisData_ST{iRef}(:,elecList_Left{iRef},:,1,:),erpData.analysisData_ST{iRef}(:,elecList_Right{iRef},:,2,:));
    contralateralRMSValsTG{iRef} = cat(2,erpData.analysisData_TG{iRef}(:,elecList_Left{iRef},:,1,:),erpData.analysisData_TG{iRef}(:,elecList_Right{iRef},:,2,:));
    
    ipsilateralRMSValsBL{iRef} = cat(2,erpData.analysisData_BL{iRef}(:,elecList_Right{iRef},:,1,:),erpData.analysisData_BL{iRef}(:,elecList_Left{iRef},:,2,:));
    ipsilateralRMSValsST{iRef} = cat(2,erpData.analysisData_ST{iRef}(:,elecList_Right{iRef},:,1,:),erpData.analysisData_ST{iRef}(:,elecList_Left{iRef},:,2,:));
    ipsilateralRMSValsTG{iRef} = cat(2,erpData.analysisData_TG{iRef}(:,elecList_Right{iRef},:,1,:),erpData.analysisData_TG{iRef}(:,elecList_Left{iRef},:,2,:));
    
    
    contralateralPSDBL{iRef} = cat(2,energyData.dataBL{iRef}(:,elecList_Left{iRef},:,1,:,:),energyData.dataBL{iRef}(:,elecList_Right{iRef},:,2,:,:));
    contralateralPSDST{iRef} = cat(2,energyData.dataST{iRef}(:,elecList_Left{iRef},:,1,:,:),energyData.dataST{iRef}(:,elecList_Right{iRef},:,2,:,:));
    contralateralPSDTG{iRef} = cat(2,energyData.dataTG{iRef}(:,elecList_Left{iRef},:,1,:,:),energyData.dataTG{iRef}(:,elecList_Right{iRef},:,2,:,:));
    
    ipsilateralPSDBL{iRef} = cat(2,energyData.dataBL{iRef}(:,elecList_Right{iRef},:,1,:,:),energyData.dataBL{iRef}(:,elecList_Left{iRef},:,2,:,:));
    ipsilateralPSDST{iRef} = cat(2,energyData.dataST{iRef}(:,elecList_Right{iRef},:,1,:,:),energyData.dataST{iRef}(:,elecList_Left{iRef},:,2,:,:));
    ipsilateralPSDTG{iRef} = cat(2,energyData.dataTG{iRef}(:,elecList_Right{iRef},:,1,:,:),energyData.dataTG{iRef}(:,elecList_Left{iRef},:,2,:,:));
    
    %     contralateralRMSValsBL{iRef} = cat(2,erpData.analysisData_BL{iRef}(:,elecList_Left{iRef},:,1,:),erpData.analysisData_BL{iRef}(:,elecList_Right{iRef},:,2,:));
    %     contralateralRMSValsST{iRef} = cat(2,erpData.analysisData_ST{iRef}(:,elecList_Left{iRef},:,1,:),erpData.analysisData_ST{iRef}(:,elecList_Right{iRef},:,2,:));
    %     contralateralRMSValsTG{iRef} = cat(2,erpData.analysisData_TG{iRef}(:,elecList_Left{iRef},:,1,:),erpData.analysisData_TG{iRef}(:,elecList_Right{iRef},:,2,:));
    %
    %     ipsilateralRMSValsBL{iRef} = cat(2,erpData.analysisData_BL{iRef}(:,elecList_Right{iRef},:,1,:),erpData.analysisData_BL{iRef}(:,elecList_Left{iRef},:,2,:));
    %     ipsilateralRMSValsST{iRef} = cat(2,erpData.analysisData_ST{iRef}(:,elecList_Right{iRef},:,1,:),erpData.analysisData_ST{iRef}(:,elecList_Left{iRef},:,2,:));
    %     ipsilateralRMSValsTG{iRef} = cat(2,erpData.analysisData_TG{iRef}(:,elecList_Right{iRef},:,1,:),erpData.analysisData_TG{iRef}(:,elecList_Left{iRef},:,2,:));
    
    for iFreqRange = 1:4
        contralateralPowerValsBL{iRef}{iFreqRange} = cat(2,energyData.analysisDataBL{iRef}{iFreqRange}(:,elecList_Left{iRef},:,1,:),energyData.analysisDataBL{iRef}{iFreqRange}(:,elecList_Right{iRef},:,2,:));
        contralateralPowerValsST{iRef}{iFreqRange} = cat(2,energyData.analysisDataST{iRef}{iFreqRange}(:,elecList_Left{iRef},:,1,:),energyData.analysisDataST{iRef}{iFreqRange}(:,elecList_Right{iRef},:,2,:));
        contralateralPowerValsTG{iRef}{iFreqRange} = cat(2,energyData.analysisDataTG{iRef}{iFreqRange}(:,elecList_Left{iRef},:,1,:),energyData.analysisDataTG{iRef}{iFreqRange}(:,elecList_Right{iRef},:,2,:));
        
        ipsilateralPowerValsBL{iRef}{iFreqRange} = cat(2,energyData.analysisDataBL{iRef}{iFreqRange}(:,elecList_Right{iRef},:,1,:),energyData.analysisDataBL{iRef}{iFreqRange}(:,elecList_Left{iRef},:,2,:));
        ipsilateralPowerValsST{iRef}{iFreqRange} = cat(2,energyData.analysisDataST{iRef}{iFreqRange}(:,elecList_Right{iRef},:,1,:),energyData.analysisDataST{iRef}{iFreqRange}(:,elecList_Left{iRef},:,2,:));
        ipsilateralPowerValsTG{iRef}{iFreqRange} = cat(2,energyData.analysisDataTG{iRef}{iFreqRange}(:,elecList_Right{iRef},:,1,:),energyData.analysisDataTG{iRef}{iFreqRange}(:,elecList_Left{iRef},:,2,:));
        
    end
end


hFig = figure(1);
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlotsFig.hPlot1 = getPlotHandles(3,2,[0.06 0.62 0.3 0.3],0.01,0.01,1); %linkaxes(hPlotsFig.hPlot1)
hPlotsFig.hPlot2 = getPlotHandles(3,2,[0.06 0.08 0.3 0.45],0.01,0.01,1);%linkaxes(hPlotsFig.hPlot2)

hPlotsFig.hPlot3 = getPlotHandles(3,2,[0.4 0.62 0.3 0.3],0.01,0.01,1); %linkaxes(hPlotsFig.hPlot3)
hPlotsFig.hPlot4 = getPlotHandles(3,2,[0.4 0.08 0.3 0.45],0.01,0.01,1);%linkaxes(hPlotsFig.hPlot4)

hPlotsFig.hPlot5 = getPlotHandles(3,2,[0.75 0.62 0.2 0.35],0.01,0.01,1);linkaxes(hPlotsFig.hPlot5)
hPlotsFig.hPlot6 = getPlotHandles(3,2,[0.75 0.14 0.2 0.35],0.01,0.01,1);linkaxes(hPlotsFig.hPlot6)


% colors = {'m','y','g','c'};
for iRef = 1:2
    for iTF = 1:3
        clear psdBL_con psdBL_ipsi psdST_con psdST_ipsi psdTG_con psdTG_ipsi
        clear rmsERP_ST_con rmsERP_TG_con rmsERP_ST_ipsi rmsERP_TG_ipsi barPlotValsST_ConvsIpsi barPlotValsTG_ConvsIpsi
        erpST_con = squeeze(mean(mean(contralateralERP_ST{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        erpST_ipsi = squeeze(mean(mean(ipsilateralERP_ST{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        
        erpTG_con = squeeze(mean(mean(contralateralERP_TG{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        erpTG_ipsi = squeeze(mean(mean(ipsilateralERP_TG{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        
        rmsERP_ST_con = squeeze(mean(contralateralRMSValsST{iRef}(subjectIdx,:,eotCodeIdx,1,iTF),2));
        rmsERP_TG_con = squeeze(mean(contralateralRMSValsTG{iRef}(subjectIdx,:,eotCodeIdx,1,iTF),2));
        
        rmsERP_ST_ipsi = squeeze(mean(ipsilateralRMSValsST{iRef}(subjectIdx,:,eotCodeIdx,1,iTF),2));
        rmsERP_TG_ipsi = squeeze(mean(ipsilateralRMSValsTG{iRef}(subjectIdx,:,eotCodeIdx,1,iTF),2));
        
        psdBL_con = squeeze(mean(mean(contralateralPSDBL{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        psdBL_ipsi = squeeze(mean(mean(ipsilateralPSDBL{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        
        psdST_con = squeeze(mean(mean(contralateralPSDST{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        psdST_ipsi = squeeze(mean(mean(ipsilateralPSDST{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        
        psdTG_con = squeeze(mean(mean(contralateralPSDTG{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        psdTG_ipsi = squeeze(mean(mean(ipsilateralPSDTG{iRef}(subjectIdx,:,eotCodeIdx,1,iTF,:),2),1));
        
        if iRef == 1
            plot(hPlotsFig.hPlot1(iTF,1),erpData.timeVals,erpST_con,'color',attendColors{1}); hold(hPlotsFig.hPlot1(iTF,1),'on')
            plot(hPlotsFig.hPlot1(iTF,1),erpData.timeVals,erpST_ipsi,'color',attendColors{2})
            plot(hPlotsFig.hPlot1(iTF,2),erpData.timeVals,erpTG_con,'color',attendColors{1}); hold(hPlotsFig.hPlot1(iTF,2),'on')
            plot(hPlotsFig.hPlot1(iTF,2),erpData.timeVals,erpTG_ipsi,'color',attendColors{2})
            
            if plotPSDFlag
            plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,psdBL_con,'color','k','LineStyle','--','DisplayNAme','BL-contra'); hold(hPlotsFig.hPlot2(iTF,1),'on')
            plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,psdBL_ipsi,'color','k','DisplayNAme','BL-ipsi')
            plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,psdST_con,'color',attendColors{1},'DisplayNAme','Attend-contra')
            plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,psdST_ipsi,'color',attendColors{2},'DisplayNAme','Attend-ipsi')
            end
            
            if plotDeltaPSDFlag
                plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,10*(psdBL_ipsi-psdBL_ipsi),'color','k','DisplayNAme','BL');hold(hPlotsFig.hPlot2(iTF,1),'on')
                plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,10*(psdST_con-psdST_ipsi),'color',[0.8500 0.3250 0.0980],'LineWidth',1.5,'DisplayNAme','AttendContra-AttendIpsi');
            end
            
            
            if plotPSDFlag
            plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,psdBL_con,'color','k'); hold(hPlotsFig.hPlot2(iTF,2),'on')
            plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,psdBL_ipsi,'color','k')
            plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,psdTG_con,'color',attendColors{1})
            plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,psdTG_ipsi,'color',attendColors{2})
            end
            
            if plotDeltaPSDFlag
                plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,10*(psdBL_ipsi-psdBL_ipsi),'color','k','DisplayNAme','BL');hold(hPlotsFig.hPlot2(iTF,2),'on')
                plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,10*(psdTG_con-psdTG_ipsi),'color',[0.8500 0.3250 0.0980],'LineWidth',1.5,'DisplayNAme','AttendContra-AttendIpsi');
            end
            
        elseif iRef==2
            
            plot(hPlotsFig.hPlot3(iTF,1),erpData.timeVals,erpST_con,'color',attendColors{1}); hold(hPlotsFig.hPlot3(iTF,1),'on')
            plot(hPlotsFig.hPlot3(iTF,1),erpData.timeVals,erpST_ipsi,'color',attendColors{2})
            plot(hPlotsFig.hPlot3(iTF,2),erpData.timeVals,erpTG_con,'color',attendColors{1}); hold(hPlotsFig.hPlot3(iTF,2),'on')
            plot(hPlotsFig.hPlot3(iTF,2),erpData.timeVals,erpTG_ipsi,'color',attendColors{2})
            
            if plotPSDFlag
                plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,psdBL_con,'color','k','LineStyle','--','DisplayNAme','BL-contra'); hold(hPlotsFig.hPlot4(iTF,1),'on')
                plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,psdBL_ipsi,'color','k','DisplayNAme','BL-ipsi')
                plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,psdST_con,'color',attendColors{1},'DisplayNAme','Attend-contra')
                plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,psdST_ipsi,'color',attendColors{2},'DisplayNAme','Attend-ipsi')
            end
            
                        
            if plotDeltaPSDFlag
                plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,10*(psdBL_ipsi-psdBL_ipsi),'color','k','DisplayNAme','BL');hold(hPlotsFig.hPlot2(iTF,1),'on')
                plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,10*(psdST_con-psdST_ipsi),'color',[0.8500 0.3250 0.0980],'LineWidth',1.5,'DisplayNAme','AttendContra-AttendIpsi');
            end
            
            if plotPSDFlag
            plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,psdBL_con,'color','k'); hold(hPlotsFig.hPlot4(iTF,2),'on')
            plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,psdBL_ipsi,'color','k')
            plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,psdTG_con,'color',attendColors{1})
            plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,psdTG_ipsi,'color',attendColors{2})
            end
            
            if plotDeltaPSDFlag
                plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,10*(psdBL_ipsi-psdBL_ipsi),'color','k','DisplayNAme','BL');hold(hPlotsFig.hPlot2(iTF,2),'on')
                plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,10*(psdTG_con-psdTG_ipsi),'color',[0.8500 0.3250 0.0980],'LineWidth',1.5,'DisplayNAme','AttendContra-AttendIpsi');
            end
            
        end
        
        
        
        mRmsERP_ST_con = mean(rmsERP_ST_con,1); semRmsERP_ST_con = std(rmsERP_ST_con,[],1)./sqrt(size(rmsERP_ST_con,1));
        mRmsERP_TG_con = mean(rmsERP_TG_con,1); semRmsERP_TG_con = std(rmsERP_TG_con,[],1)./sqrt(size(rmsERP_TG_con,1));
        
        mRmsERP_ST_ipsi = mean(rmsERP_ST_ipsi,1); semRmsERP_ST_ipsi = std(rmsERP_ST_ipsi,[],1)./sqrt(size(rmsERP_ST_ipsi,1));
        mRmsERP_TG_ipsi = mean(rmsERP_TG_ipsi,1); semRmsERP_TG_ipsi = std(rmsERP_TG_ipsi,[],1)./sqrt(size(rmsERP_TG_ipsi,1));
        
        barPlotValsST_ConvsIpsi = mRmsERP_ST_con -mRmsERP_ST_ipsi;
        barPlotValsTG_ConvsIpsi = mRmsERP_TG_con -mRmsERP_TG_ipsi;
        
        semValsST_ConvsIpsi = semRmsERP_ST_con - semRmsERP_ST_ipsi;
        semValsTG_ConvsIpsi = semRmsERP_TG_con - semRmsERP_TG_ipsi;
        
        for iFreqRange = 1:4
            clear powerValsBL_con powerValsST_con powerValsTG_con powerValsBL_ipsi powerValsST_ipsi powerValsTG_ipsi
            powerValsBL_con = squeeze(mean(contralateralPowerValsBL{iRef}{iFreqRange}(subjectIdx,:,eotCodeIdx,1,iTF),2));
            powerValsST_con = squeeze(mean(contralateralPowerValsST{iRef}{iFreqRange}(subjectIdx,:,eotCodeIdx,1,iTF),2));
            powerValsTG_con = squeeze(mean(contralateralPowerValsTG{iRef}{iFreqRange}(subjectIdx,:,eotCodeIdx,1,iTF),2));
            
            powerValsBL_ipsi = squeeze(mean(ipsilateralPowerValsBL{iRef}{iFreqRange}(subjectIdx,:,eotCodeIdx,1,iTF),2));
            powerValsST_ipsi = squeeze(mean(ipsilateralPowerValsST{iRef}{iFreqRange}(subjectIdx,:,eotCodeIdx,1,iTF),2));
            powerValsTG_ipsi = squeeze(mean(ipsilateralPowerValsTG{iRef}{iFreqRange}(subjectIdx,:,eotCodeIdx,1,iTF),2));
            
            % mean and sem across subjects
            mPowerValsBL_con = mean(powerValsBL_con,1); semPowerValsBL_con = std(powerValsBL_con,[],1)./sqrt(size(powerValsBL_con,1));
            mPowerValsST_con = mean(powerValsST_con,1); semPowerValsST_con = std(powerValsST_con,[],1)./sqrt(size(powerValsST_con,1));
            mPowerValsTG_con = mean(powerValsTG_con,1); semPowerValsTG_con = std(powerValsTG_con,[],1)./sqrt(size(powerValsTG_con,1));
            
            mPowerValsBL_ipsi = mean(powerValsBL_ipsi,1); semPowerValsBL_ipsi = std(powerValsBL_ipsi,[],1)./sqrt(size(powerValsBL_ipsi,1));
            mPowerValsST_ipsi = mean(powerValsST_ipsi,1); semPowerValsST_ipsi = std(powerValsST_ipsi,[],1)./sqrt(size(powerValsST_ipsi,1));
            mPowerValsTG_ipsi = mean(powerValsTG_ipsi,1); semPowerValsTG_ipsi = std(powerValsTG_ipsi,[],1)./sqrt(size(powerValsTG_ipsi,1));
            
            
            barPlotValsST_TMP_ConvsIpsi = 10*(mPowerValsST_con-mPowerValsST_ipsi);
            barPlotValsTG_TMP_ConvsIpsi = 10*(mPowerValsTG_con-mPowerValsTG_ipsi);
            
            barPlotValsST_ConvsIpsi(iFreqRange+1,:) = barPlotValsST_TMP_ConvsIpsi; %#ok<*AGROW>
            barPlotValsTG_ConvsIpsi(iFreqRange+1,:) = barPlotValsTG_TMP_ConvsIpsi; %#ok<*AGROW>
            
            semValsST_ConvsIpsi(iFreqRange+1,:) = 10*(semPowerValsST_con-semPowerValsST_ipsi);
            semValsTG_ConvsIpsi(iFreqRange+1,:) = 10*(semPowerValsTG_con-semPowerValsTG_ipsi);
            
            %         bl(1).FaceColor = 'm'; bl(2).FaceColor = 'y'; bl(3).FaceColor = 'g'; bl(3).FaceColor = 'c';
        end
        
        if iTF ==1
            colors = {'y', 'k','m'};
            barPlotValsST_ConvsIpsi(4:5,:) = [];
            barPlotValsTG_ConvsIpsi(4:5,:) = [];
            semValsST_ConvsIpsi(4:5,:) = [];
            semValsTG_ConvsIpsi(4:5,:) = [];
            
        else
            colors = {'y', 'k','m','g','c'};
        end
        
        for iBar = 1:length(barPlotValsST_ConvsIpsi)
            if iRef ==1
                bl = bar(iBar,barPlotValsST_ConvsIpsi(iBar),colors{iBar},'parent',hPlotsFig.hPlot5(iTF,1)); hold(hPlotsFig.hPlot5(iTF,1),'on')
                b2 = bar(iBar,barPlotValsTG_ConvsIpsi(iBar),colors{iBar},'parent',hPlotsFig.hPlot5(iTF,2));hold(hPlotsFig.hPlot5(iTF,2),'on')
                
            elseif iRef ==2

                b3 = bar(iBar,barPlotValsST_ConvsIpsi(iBar),colors{iBar},'parent',hPlotsFig.hPlot6(iTF,1)); hold(hPlotsFig.hPlot6(iTF,1),'on')
                b4 = bar(iBar,barPlotValsTG_ConvsIpsi(iBar),colors{iBar},'parent',hPlotsFig.hPlot6(iTF,2));hold(hPlotsFig.hPlot6(iTF,2),'on')
            end
        end
        
        if iRef ==1
            errorbar(hPlotsFig.hPlot5(iTF,1),1:length(barPlotValsST_ConvsIpsi),barPlotValsST_ConvsIpsi,semValsST_ConvsIpsi,'.','color','k')
            errorbar(hPlotsFig.hPlot5(iTF,2),1:length(barPlotValsST_ConvsIpsi),barPlotValsTG_ConvsIpsi,semValsTG_ConvsIpsi,'.','color','k')
        elseif iRef ==2
            errorbar(hPlotsFig.hPlot6(iTF,1),1:length(barPlotValsST_ConvsIpsi),barPlotValsST_ConvsIpsi,semValsST_ConvsIpsi,'.','color','k')
            errorbar(hPlotsFig.hPlot6(iTF,2),1:length(barPlotValsST_ConvsIpsi),barPlotValsTG_ConvsIpsi,semValsTG_ConvsIpsi,'.','color','k')
        end
        
        if iTF==3
            set(hPlotsFig.hPlot5(iTF,1),'XTick',1:5);set(hPlotsFig.hPlot5(iTF,2),'XTick',1:5)
            set(hPlotsFig.hPlot6(iTF,1),'XTick',1:5);set(hPlotsFig.hPlot6(iTF,2),'XTick',1:5)
        end
    end
end


%     legend('BL-Attend Contra','BL-Attend Ipsi','Attend Contra', 'Attend Ipsi','parent',hPlotsFig.hPlot2,hPlotsFig.hPlot2(1,1))

% xlim(hPlotsFig.hPlot1(1,1),[-1.000 1.250]); ylim(hPlotsFig.hPlot1(1,1),[-10 5]);
% xlim(hPlotsFig.hPlot3(1,1),[-1.000 0]);ylim(hPlotsFig.hPlot3(1,1),[-10 5]);
% xlim(hPlotsFig.hPlot4(1,1),[0 100]);ylim(hPlotsFig.hPlot4(1,1),[-6 6]);
% xlim(hPlotsFig.hPlot2(1,1),[0 100]);ylim(hPlotsFig.hPlot2(1,1),[-6 6]);
% ylim(hPlotsFig.hPlot5(1,1),[-1 1]);ylim(hPlotsFig.hPlot6(1,1),[-1 1]);

% For topoplots
% cLimsTopo = [-1 3];
% showMode = 'dots'; showElecs = [93 94 101 102 96 97 111 107 112];
%
% % Get the electrode list
% clear cL bL chanlocs iElec electrodeList
% switch refType
%     case 'unipolar'
%         cL = load(fullfile(pwd,'Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
%         chanlocs = cL.chanlocs;
%         for iElec = 1:length(chanlocs)
%             electrodeList{iElec}{1} = iElec;
%         end
%     case 'bipolar'
%         cL = load(fullfile(pwd,'Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
%         bL = load(fullfile(pwd,'Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat']));
%         chanlocs = cL.eloc;
%         for iElec = 1:length(chanlocs)
%             electrodeList{iElec}{1} = bL.bipolarLocs(iElec,:);
%         end
% end

title(hPlotsFig.hPlot1(1,1),'Stim Onset');title(hPlotsFig.hPlot1(1,2),'Target Onset');
title(hPlotsFig.hPlot3(1,1),'Stim Onset');title(hPlotsFig.hPlot3(1,2),'Target Onset');
title(hPlotsFig.hPlot5(1,1),'Stim Onset');title(hPlotsFig.hPlot5(1,2),'Target Onset');
xlabel(hPlotsFig.hPlot1(3,1),'time (s)'); ylabel(hPlotsFig.hPlot1(3,1),'\muV');
xlabel(hPlotsFig.hPlot2(3,1),'time (s)'); ylabel(hPlotsFig.hPlot2(3,1),'\muV');
ylabel(hPlotsFig.hPlot5(3,1),'Change in Power (dB)'); ylabel(hPlotsFig.hPlot6(3,1),'Change in Power (dB)')

if plotPSDFlag
xlabel(hPlotsFig.hPlot2(3,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot2(3,1),'log_1_0 [power (\muV^2)]');
xlabel(hPlotsFig.hPlot4(3,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot4(3,1),'log_1_0 [power (\muV^2)]');
end

if plotDeltaPSDFlag
xlabel(hPlotsFig.hPlot2(3,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot2(3,1),'Change in Power (dB)');
xlabel(hPlotsFig.hPlot4(3,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot4(3,1),'Change in Power (dB)');
end
% legend

tickLengthPlot = 1.5*get(hPlotsFig.hPlot1(1,1),'TickLength');

set(hPlotsFig.hPlot1,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot2,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot3,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot4,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot5,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot6,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)

stringLabels{1} = 'rms ERP (\muV)';
stringLabels{2} = '\alpha (8-12 Hz)';
stringLabels{3} = '\gamma (42-78 Hz)';
stringLabels{4} = 'SSVEP-24 Hz';
stringLabels{5} = 'SSVEP-32 Hz';


set(hPlotsFig.hPlot5(3,1),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);
set(hPlotsFig.hPlot6(3,1),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);
set(hPlotsFig.hPlot5(3,2),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);
set(hPlotsFig.hPlot6(3,2),'XTickLabel',stringLabels,'XTickLabelRotation',45,'fontSize',8);

rescaleData(hPlotsFig.hPlot1(:,1),-1.000,1.250,[-10 5],12,0);
rescaleData(hPlotsFig.hPlot1(:,2),-1.000,0,[-10 5],12,2);
rescaleData(hPlotsFig.hPlot3(:,1),-1.000,1.250,[-10 5],12,0);
rescaleData(hPlotsFig.hPlot3(:,2),-1.000,0,[-10 5],12,2);
rescaleData(hPlotsFig.hPlot2,0,100,[-5 5],12,0);
rescaleData(hPlotsFig.hPlot4,0,100,[-5 5],12,0);
rescaleData(hPlotsFig.hPlot5,0,6,[-2 3],12,0);
rescaleData(hPlotsFig.hPlot6,0,6,[-2 3],12,0);

% 
% legend(hPlotsFig.hPlot2(1,1),'FontSize',8, 'Location','northeast','box','off','LineWidth',2);
% legend('off');

textH1 = getPlotHandles(1,1,[0.17 0.97 0.01 0.01]);
textH2 = getPlotHandles(1,1,[0.52 0.97 0.01 0.01]);


textString1 = 'Unipolar';

textString2 = 'Bipolar';

set(textH1,'Visible','Off'); set(textH2,'Visible','Off')
text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH1);
text(0.35,1.15,textString2,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH2);




if eotCodeIdx ==1
    EOTCode = 'Hits';
elseif eotCodeIdx ==2
    EOTCode = 'Misses';
end

displayRange(hPlotsFig.hPlot2,[8 12],[-5 5],'k','solid-solid')
displayRange(hPlotsFig.hPlot2,[42 78],[-5 5],'m','solid-solid')
displayRange(hPlotsFig.hPlot2(2:3,:),[23 23],[-5 5],'g','solid-solid')
displayRange(hPlotsFig.hPlot2(2:3,:),[31 31],[-5 5],'c','solid-solid')

displayRange(hPlotsFig.hPlot4,[8 12],[-5 5],'k','solid-solid')
displayRange(hPlotsFig.hPlot4,[42 78],[-5 5],'m','solid-solid')
displayRange(hPlotsFig.hPlot4(2:3,:),[23 23],[-5 5],'g','solid-solid')
displayRange(hPlotsFig.hPlot4(2:3,:),[31 31],[-5 5],'c','solid-solid')

figName = fullfile(folderSourceString,[protocolType '_new2_allSubjects_N_7_analysisMethod',num2str(analysisMethodFlag) '_plotPSDFlag' num2str(plotPSDFlag) '_plotDeltaPSDFlag' num2str(plotDeltaPSDFlag)  '_EOTCode_' num2str(EOTCode) '_tapers_' , num2str(tapers(2))]);
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

