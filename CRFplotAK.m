for i=1:2
if i == 1;
load('H:\data\AK\EEG\080616\GRF_0001\extractedData\parameterCombinations.mat');
load('H:\data\AK\EEG\080616\GRF_0001\segmentedData\LFP\lfpInfo.mat');
load('H:\data\AK\EEG\080616\GRF_0001\segmentedData\LFP\elec31.mat');
else
load('H:\data\AK\EEG\080616\GRF_0002\extractedData\parameterCombinations.mat');
load('H:\data\AK\EEG\080616\GRF_0002\segmentedData\LFP\lfpInfo.mat');
load('H:\data\AK\EEG\080616\GRF_0002\segmentedData\LFP\elec31.mat');
end
s = 1; f = 1; o =2; t= 1; 
blPeriod = [-0.2 0]; erpPeriod = [0.05 0.25];
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
                legend('0','12.5','25','50','100'); hold off;
            end
            ylim(locPlotHandle,yLims); xlim(locPlotHandle,xLims); title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
            
            % 
            erpPos = (timeVals>erpPeriod(1) & timeVals<=erpPeriod(2));
            rmsERPdata(a,e,c) = rms(ERPdata(:,erpPos));
        end
        
    end
    
end

figure(3)
hold on;
subplot(1,2,i);    
crf1= squeeze(rmsERPdata(1,1,:));
plot(log2(cValsUnique),crf1,'o-');hold on
crf2= squeeze(rmsERPdata(1,2,:));
plot(log2(cValsUnique),crf2,'o-');

crf3= squeeze(rmsERPdata(2,1,:));
plot(log2(cValsUnique),crf3,'o-');

crf4= squeeze(rmsERPdata(2,2,:));
plot(log2(cValsUnique),crf4,'o-'); hold on;
legend('a = -4, e = -4','a = -4, e = 0','a = 0, e = -4','a = 0, e = 0');
end

