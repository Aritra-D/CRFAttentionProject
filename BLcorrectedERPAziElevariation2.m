load('H:\data\DJ\EEG\140616\GRF_0001\extractedData\parameterCombinations.mat');
load('H:\data\DJ\EEG\140616\GRF_0001\segmentedData\LFP\lfpInfo.mat');
load('H:\data\DJ\EEG\140616\GRF_0001\segmentedData\LFP\elec31.mat');
                
s = 1; f = 1; c = 1 ; t= 1; 
blPeriod = [-0.2 0];
yLims = [-15 15]; xLims = [-0.2 0.7];
% figure;
plotPos = [0.1 0.1 0.8 0.8]; plotGap = 0.05;
plotHandles = getPlotHandles(length(aValsUnique),length(eValsUnique),plotPos,plotGap,plotGap*2,0);

for o=1:length(oValsUnique)
    figure(o);
    for a = 1:length(aValsUnique)
        for e = 1:length(eValsUnique)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear goodPos
            goodPos = parameterCombinations{a,e,s,f,o,c,t};

            clear dataToAnalyse
            dataToAnalyse = analogData(goodPos,:);

            clear blPos data datamean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
            blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
            data = dataToAnalyse(:,blPos);
            datamean = mean(data,2);
            sizeDTA = size(dataToAnalyse,2);
            dataToAnalyseBLMatrix = repmat(datamean,1,sizeDTA);
            %dataToAnalyseBLMatrix = repmat(mean(dataToAnalyse(:,blPos),2),1,size(dataToAnalyse,2));
            dataToAnalyseBLCorrected = dataToAnalyse - dataToAnalyseBLMatrix;

            
            for iLoop = 1:size(dataToAnalyseBLCorrected,1)
                plot(timeVals,dataToAnalyseBLCorrected(iLoop,:));
                hold on
             %  pause;
            end

%             subplot(plotHandles(a,e));
            subplot(2,2,2*(a-1)+e);
          plot(timeVals,dataToAnalyseBLCorrected,'color',[0.5 0.5 0.5],'linewidth',1); hold on;
            plot(timeVals,mean(dataToAnalyseBLCorrected,1),'color','k','linewidth',2); axis tight; hold off
            ylim(yLims); xlim(xLims); title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
        end
    end
end