% This section Generates the ERP for six Contrast Conditions for subjects 
% who performed GRF Protocol for all the spatial location of stimuli

clear; clc; close all;
load('H:\Programs\DataMAP\ReceptiveFieldData\kesariMicroelectrodeRFData.mat')
electrodeNumLists{1} = [highRMSElectrodes]; % Electrodes of Interest
%electrodeNumLists{2} = [29 28 60 61]; % Electrodes of Interest

blPeriod = [-0.2 0]; erpPeriod = [0.05 0.25];
s=1; f=1; o=1; t=1;

yLims = [-300 250]; xLims = [-0.2 0.7];
plotPos = [0.1 0.1 0.8 0.8]; plotGap = 0.05;

indexList = 469;%[];
[expDates,protocolNames,stimType] = getAllProtocols('kesari','Microelectrode');
folderSourceString='H:'; subjectName = 'kesari'; gridType = 'Microelectrode';

for i=1:length(indexList)
    %subjectName = subjectNames{indexList(i)};
    expDate = expDates{indexList(i)};
    protocolName = protocolNames{indexList(i)};
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','parameterCombinations.mat'));    
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP','lfpInfo.mat'));           
    
    blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
    erpPos = (timeVals>erpPeriod(1) & timeVals<=erpPeriod(2));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(i);
    plotHandles = getPlotHandles(length(aValsUnique),length(eValsUnique),plotPos,plotGap,plotGap*2,0);
    contrastColor = hsv(length(cValsUnique));
    electrodeNumList = electrodeNumLists{1}; % Right Side
    
    for a=1:length(aValsUnique)
        for e=1:length(eValsUnique)
            for c=1:length(cValsUnique)
                clear goodPos
                goodPos =setdiff(parameterCombinations{a,e,s,f,o,c,t},[]);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                analogData = [];
                for j = 1:length(electrodeNumList) % Rigth side
                    elecNum = electrodeNumList(j);
                    electrodeData = load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP',['elec' num2str(elecNum) '.mat']));
                    analogData = cat(1,analogData,electrodeData.analogData(goodPos,:));
                end
       
                clear dataMean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
                
                dataMean = mean(analogData(:,blPos),2);
                sizeDTA = size(analogData,2);
                dataToAnalyseBLMatrix = repmat(dataMean,1,sizeDTA);
                dataToAnalyseBLCorrected = analogData - dataToAnalyseBLMatrix;
                erpData = mean(dataToAnalyseBLCorrected,1);
                
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

                  hold on;
                  plot(timeVals,erpData,'color',contrastColor(c,:),'linewidth',1);
                
                rmsERPdata(a,e,c) = rms(erpData(:,erpPos)) - rms(erpData(:,blPos));
            end
            
            legend('0','1.62','3.125','6.25','12.5','25','50','100');
            ylim(yLims); 
            xlim(xLims); 
            title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
            xlabel('Time(second)'); 
            ylabel('Voltage Amplitude(µV)');
            
            
%             legend(locPlotHandle,'0','6.25','12.5','25','50','100');
%             ylim(locPlotHandle,yLims); 
%             xlim(locPlotHandle,xLims); 
%             title(locPlotHandle,['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
%             xlabel(locPlotHandle,'Time(second)'); 
%             ylabel(locPlotHandle,'Voltage Amplitude(µV)');
        end
    end
    
%     % This section generates the contrast response functions for all the four spatial locations for the two subjects
    figure(length(indexList)+1);
    hold on;
%     % This section generates the contrast response functions for all the four spatial locations for the two subjects
%     subplot(1,2,i);
    scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
    crf1= squeeze(rmsERPdata(1,1,:));
    plot(scaledxaxis,crf1,'ro-');hold on;
    plotPsychometricFunction(scaledxaxis,crf1,'r',[1 1 11])
%     crf2= squeeze(rmsERPdata(1,2,:));
%     % plot(scaledxaxis,crf2,'bo');
%     plotPsychometricFunction(scaledxaxis,crf2,'b',[1 1 11])
%     crf3= squeeze(rmsERPdata(2,1,:));
%     % plot(scaledxaxis,crf3,'ko');
%     plotPsychometricFunction(scaledxaxis,crf3,'k',[1 1 11])
%     crf4= squeeze(rmsERPdata(2,2,:));
%     % plot(scaledxaxis,crf4,'co');
%     plotPsychometricFunction(scaledxaxis,crf4,'c',[1 1 11]);
    hold on;
%     
    ax = gca;
    ax.XTick = [scaledxaxis];
    ax.XTickLabel = {'0','3.125','6.25', '12.5', '25', '50', '100'};
%     % xlim([1.643 6.644]);
%     legend('','a = -6, e = -6','','a = -6, e = 0','','a = 0, e = -6','','a = 0, e = 0');
    ylabel('RMS value of ERP Amplitude'); xlabel('Contrast(%)');
    title('Contrast Response for Monkey T');
end