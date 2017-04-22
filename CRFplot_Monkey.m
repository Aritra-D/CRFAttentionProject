% This code Generates the ERP for Eight Contrast Conditions for monkey 
% who performed GRF Protocol for all the spatial location of stimuli

clear; close all; %clc;

blPeriod = [-0.2 0]; erpPeriod = [0.05 0.25];
a = 1; e = 1; s = 1; f = 1; t = 1; % Stimulus Parameters

yLims = [-1200 250]; xLims = [-0.2 1.5];
plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

% Data Loading 
indexList = 473;%[];
[expDates,protocolNames,stimType] = getAllProtocols('kesari','Microelectrode');
folderSourceString='H:'; subjectName = 'kesari'; gridType = 'Microelectrode';
load(fullfile(folderSourceString,'programs','DataMap','ReceptiveFieldData',[subjectName,'MicroelectrodeRFData.mat']));
electrodeNumLists{1} = [highRMSElectrodes([1 2 3])]; % Electrodes of Interest


for i=1:length(indexList)
    %subjectName = subjectNames{indexList(i)};
    expDate = expDates{indexList(i)};
    protocolName = protocolNames{indexList(i)};
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
    load(fullfile(folderName,'extractedData','parameterCombinations.mat'));    
    load(fullfile(folderName,'segmentedData','LFP','lfpInfo.mat'));           
    
    blPos = find(timeVals>blPeriod(1) & timeVals<=blPeriod(2));
    erpPos = find(timeVals>erpPeriod(1) & timeVals<=erpPeriod(2));
    
    % Get bad trials

    folderExtract = fullfile(folderName,'extractedData');
    folderSegment = fullfile(folderName,'segmentedData');
    badTrialFile = fullfile(folderSegment,'badTrialsNew.mat');
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badTrials=[];
    else
        badTrials = load(badTrialFile);
        disp([num2str(length(badTrials)) ' bad trials']);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(i);
    [plotHandlesERP,~,plotPosERP] = getPlotHandles(length(cValsUnique)/4,length(cValsUnique)/2,plotPos,plotGap,plotGap*2,0);
    oriColor = hsv(length(oValsUnique));
    
    electrodeNumList = electrodeNumLists{1}; 
    
            for c=1:length(cValsUnique)
                analogData = [];
                clear analogDataElecwise BaselineAnalogDataElecwise ...
                    AnalogDataBLMatrix analogDataBLCorrected ...
                    ERPDataBLCorrected
                clear goodPos
                
                % Variable declaration
                analogDataElecwise = cell(length(oValsUnique),length(electrodeNumList));
                BaselineAnalogDataElecwise = cell(length(oValsUnique),length(electrodeNumList));
                AnalogDataBLMatrix = cell(length(oValsUnique),length(electrodeNumList));
                analogDataBLCorrected = cell(length(oValsUnique),length(electrodeNumList));
                ERPDataBLCorrected = cell(length(oValsUnique),length(electrodeNumList));
                
                    for iOri = 1:length(oValsUnique) 
                        goodPos =setdiff(parameterCombinations{a,e,s,f,iOri,c,t},[]);
                        goodPos = setdiff(goodPos,badTrials.badTrials);
                        
                        for j = 1:length(electrodeNumList)
                            disp(num2str([cValsUnique(c) iOri j]));
                            elecNum = electrodeNumList(j);
                            electrodeData = load(fullfile(folderSourceString,'data',subjectName,...
                                gridType,expDate,protocolName,'segmentedData','LFP',['elec' num2str(elecNum) '.mat']));
                            analogDataElecwise{iOri,j} = electrodeData.analogData(goodPos,:);
                            BaselineAnalogDataElecwise{iOri,j} = mean(analogDataElecwise{iOri,j}(:,blPos),2);
                            sizeDTA = size(analogDataElecwise{i,j},2);
                            AnalogDataBLMatrix{iOri,j} = repmat(BaselineAnalogDataElecwise{iOri,j},1,sizeDTA);
                            analogDataBLCorrected{iOri,j} = analogDataElecwise{iOri,j} - AnalogDataBLMatrix{iOri,j}; 
                            ERPDataBLCorrected{iOri,j} = mean(analogDataBLCorrected{iOri,j},1);
                        end
                    end
                    ERPdataAggregate = zeros(1,sizeDTA); ERPdataAggreElec = zeros(1,sizeDTA); ERPdataOriAggre = zeros(1,sizeDTA);
                    ERPdataElecAvg = cell(length(oValsUnique),1);
                    for iOri = 1:length(oValsUnique)
                        for iElec = 1:size(analogDataElecwise,2)
                            ERPdataAggregate = ERPdataAggregate + ERPDataBLCorrected{iOri,iElec};
                        end
                        ERPdataElecAvg{iOri,:}=ERPdataAggregate/length(electrodeNumList);
                        figure(i); hold on,
                        subplot(plotHandlesERP(c));
                        xlim(xLims);ylim(yLims);
                        plot(timeVals,ERPdataElecAvg{iOri,:},'color',oriColor(iOri,:),'linewidth',1);
                        legend('0','30','60','90','120','150');
                        
                        ERPdataOriAggre = ERPdataAggreElec + ERPdataElecAvg{iOri,:};
                    end
                    
                    ERPdataOriAvg = ERPdataOriAggre/length(oValsUnique);
                    ContrastColor = jet(length(cValsUnique));
                    figure(i+length(indexList));
                    hold on;
                    plot(timeVals, ERPdataOriAvg,'color',ContrastColor(c,:),'LineWidth',1);
                    xlim(xLims);ylim([-200 50]);legend('0','1.5','3.1','6.2','12.5','25','50','100');
                            
                
                
%                 if (a==1) && (e==1)
%                     locPlotHandle = plotHandles(2,1);
%                 elseif (a==1) && (e==2)
%                     locPlotHandle = plotHandles(1,1);
%                 elseif (a==2) && (e==1)
%                     locPlotHandle = plotHandles(2,2);
%                 elseif (a==2) && (e==2)
%                     locPlotHandle = plotHandles(1,2);
%                 end
                    
%                 hold(locPlotHandle,'on');
%                 plot(locPlotHandle,timeVals,erpData,'color',contrastColor(c,:),'linewidth',1);

%                   hold on;
%                   plot(timeVals,erpData,'color',contrastColor(c,:),'linewidth',1);
%                 
%                 rmsERPdata(a,e,c) = rms(erpData(:,erpPos)) - rms(erpData(:,blPos));
            end
%             
%             legend('0','1.62','3.125','6.25','12.5','25','50','100');
%             ylim(yLims); 
%             xlim(xLims); 
%             title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
%             xlabel('Time(second)'); 
%             ylabel('Voltage Amplitude(µV)');
%             
%             
% %             legend(locPlotHandle,'0','6.25','12.5','25','50','100');
% %             ylim(locPlotHandle,yLims); 
% %             xlim(locPlotHandle,xLims); 
% %             title(locPlotHandle,['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
% %             xlabel(locPlotHandle,'Time(second)'); 
% %             ylabel(locPlotHandle,'Voltage Amplitude(µV)');
% %         end
% %     end
% 
% %     % This section generates the contrast response functions for all the four spatial locations for the two subjects
%     figure(length(indexList)+1);
%     hold on;
% %     % This section generates the contrast response functions for all the four spatial locations for the two subjects
% %     subplot(1,2,i);
%     scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
%     crf1= squeeze(rmsERPdata(1,1,:));
%     plot(scaledxaxis,crf1,'ro-');hold on;
%     plotPsychometricFunction(scaledxaxis,crf1,'r',[1 1 11])
% %     crf2= squeeze(rmsERPdata(1,2,:));
% %     % plot(scaledxaxis,crf2,'bo');
% %     plotPsychometricFunction(scaledxaxis,crf2,'b',[1 1 11])
% %     crf3= squeeze(rmsERPdata(2,1,:));
% %     % plot(scaledxaxis,crf3,'ko');
% %     plotPsychometricFunction(scaledxaxis,crf3,'k',[1 1 11])
% %     crf4= squeeze(rmsERPdata(2,2,:));
% %     % plot(scaledxaxis,crf4,'co');
% %     plotPsychometricFunction(scaledxaxis,crf4,'c',[1 1 11]);
%     hold on;
% %     
%     ax = gca;
%     ax.XTick = [scaledxaxis];
%     ax.XTickLabel = {'0','3.125','6.25', '12.5', '25', '50', '100'};
% %     % xlim([1.643 6.644]);
% %     legend('','a = -6, e = -6','','a = -6, e = 0','','a = 0, e = -6','','a = 0, e = 0');
%     ylabel('RMS value of ERP Amplitude'); xlabel('Contrast(%)');
%     title('Contrast Response for Monkey T');
end