
%% This section Generates the ERP for six Contrast Conditions for two subjects GRF Protocol for all the spatial location of stimuli
clear; clc; close all;
fig3H = figure(3);
for i=1:2
if i == 1; 
    % Occipital     %Parieto-occipital
load('H:\data\DJ\EEG\140616\GRF_0002\extractedData\parameterCombinations.mat');    % Electrodes of Interest(Left)       29 (O1)    28(PO9),60(PO7),61(PO3)
load('H:\data\DJ\EEG\140616\GRF_0002\segmentedData\LFP\lfpInfo.mat');              % Electrodes of Interest(Right)      31 (O2)    32(PO10),63(PO4),64(PO8)
load('H:\data\DJ\EEG\140616\GRF_0002\segmentedData\badTrials.mat');
analogData = []; badTrialsAllElec = []; totTrials = 0; 
%     for elecNum = [31 32 63 64]
%         clear ElectrodeData analogDataSingleElec badTrialsElec
%         ElectrodeData = load(['H:\data\DJ\EEG\140616\GRF_0002\segmentedData\LFP\elec',num2str(elecNum),'.mat']);
%         analogDataSingleElec = ElectrodeData.analogData;
%         analogData = cat(1,analogData,analogDataSingleElec);        
%         badTrialsElec = allBadTrials{elecNum} + totTrials;
%         badTrialsAllElec = union(badTrialsAllElec,badTrialsElec);
%         totTrials = size(analogData,1);        
%     end
blPeriod = [-0.2 0]; erpPeriod = [0.05 0.25];
else
load('H:\data\MD\EEG\160616\GRF_0002\extractedData\parameterCombinations.mat');
load('H:\data\MD\EEG\160616\GRF_0002\segmentedData\LFP\lfpInfo.mat');
load('H:\data\MD\EEG\160616\GRF_0002\segmentedData\badTrials.mat');
blPeriod = [-0.2 0]; erpPeriod = [0.05 0.25];
end
s = 1; f = 1; o =1; t= 1; 
yLims = [-30 15]; xLims = [-0.2 0.7];
 figure;
plotPos = [0.1 0.1 0.8 0.8]; plotGap = 0.05;
plotHandles = getPlotHandles(length(aValsUnique),length(eValsUnique),plotPos,plotGap,plotGap*2,0);
contrastColor = hsv(length(cValsUnique));

for c=1:length(cValsUnique)
%     figure(c);
    for a = 1:length(aValsUnique)
        for e = 1:length(eValsUnique)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            analogData = []; %badTrialsAllElec = []; totTrials = 0; 
            for elecNum = [31 32 63 64];%[26+32 26 31+32 31] ;%[26+32 26 31+32 31];%
                clear ElectrodeData analogDataSingleElec %badTrialsElec
                if i==1
                ElectrodeData = load(['H:\data\DJ\EEG\140616\GRF_0002\segmentedData\LFP\elec',num2str(elecNum),'.mat']);
                elseif i==2
                  ElectrodeData = load(['H:\data\MD\EEG\160616\GRF_0002\segmentedData\LFP\elec',num2str(elecNum),'.mat']);   
                else
                end
                analogDataSingleElec = ElectrodeData.analogData;
                
                clear goodPos
                goodPos =setdiff(parameterCombinations{a,e,s,f,o,c,t},allBadTrials{elecNum});
                analogData = cat(1,analogData,analogDataSingleElec(goodPos,:));   
            end
            
            clear dataToAnalyse
            dataToAnalyse = analogData;%(goodPos,:);

            clear blPos data datamean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
            blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
            data = dataToAnalyse(:,blPos);
            datamean = mean(data,2);
            sizeDTA = size(dataToAnalyse,2);
            dataToAnalyseBLMatrix = repmat(datamean,1,sizeDTA);
            %dataToAnalyseBLMatrix = repmat(mean(dataToAnalyse(:,blPos),2),1,size(dataToAnalyse,2));
            dataToAnalyseBLCorrected = dataToAnalyse - dataToAnalyseBLMatrix;
            ERPdata = mean(dataToAnalyseBLCorrected,1);

            % figure (1);
            % for iLoop = 1:size(dataToAnalyseBLCorrected,1)
            %     plot(timeVals,dataToAnalyseBLCorrected(iLoop,:));
            % %     hold on
            %     pause;
            % end

%             subplot(plotHandles(a,e));
            clear locPlotHandle
            locPlotHandle = subplot(2,2,2*(a-1)+e); 
            hold on;
%             plot(timeVals,dataToAnalyseBLCorrected,'color',[0.5 0.5 0.5],'linewidth',1); hold on;
            plot(timeVals,ERPdata,'color',contrastColor(c,:),'linewidth',1); axis tight; 
            if c==length(cValsUnique)
                legend('0','6.25','12.5','25','50','100'); hold off;
            end
            ylim(locPlotHandle,yLims); xlim(locPlotHandle,xLims); title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
            xlabel('Time(second)'); ylabel('Voltage Amplitude(µV)');
            % 
            erpPos = (timeVals>erpPeriod(1) & timeVals<=erpPeriod(2));            
            rmsERPdata(a,e,c) = rms(ERPdata(:,erpPos)) - rms(ERPdata(:,blPos));
        end
        
    end
    
end
%% This section generates the contrast response functions for all the four spatial locations for the two subjects
figure(fig3H);
hold on;
subplot(1,2,i);
scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
crf1= squeeze(rmsERPdata(1,1,:));
%plot(scaledxaxis,crf1,'ro');hold on;
plotPsychometricFunction(scaledxaxis,crf1,'r',[1 1 11])
crf2= squeeze(rmsERPdata(1,2,:));
% plot(scaledxaxis,crf2,'bo');
plotPsychometricFunction(scaledxaxis,crf2,'b',[1 1 11])
crf3= squeeze(rmsERPdata(2,1,:));
% plot(scaledxaxis,crf3,'ko');
plotPsychometricFunction(scaledxaxis,crf3,'k',[1 1 11])
crf4= squeeze(rmsERPdata(2,2,:));
% plot(scaledxaxis,crf4,'co');
plotPsychometricFunction(scaledxaxis,crf4,'c',[1 1 11]);
hold on;

ax = gca;
ax.XTick = [scaledxaxis];
ax.XTickLabel = {'0','6.25', '12.5', '25', '50', '100'};
% xlim([1.643 6.644]); 
legend('','a = -6, e = -6','','a = -6, e = 0','','a = 0, e = -6','','a = 0, e = 0');
ylabel('RMS value of ERP Amplitude'); xlabel('Contrast(%)');
title(['Contrast Response for different spatial locations for Subject:' num2str(i) ]);

end



