load('H:\data\MD\EEG\160616\GRF_0002\extractedData\parameterCombinations.mat');
load('H:\data\MD\EEG\160616\GRF_0002\segmentedData\LFP\lfpInfo.mat');
load('H:\data\MD\EEG\160616\GRF_0002\segmentedData\LFP\elec32.mat');
blPeriod = [-0.2 0]; erpPeriod = [0.05 0.25];

s = 1; f = 1; o =1; t= 2; 
yLims = [-30 15]; xLims = [-0.2 0.7];
 figure;
plotPos = [0.1 0.1 0.8 0.8]; plotGap = 0.05;
plotHandles = getPlotHandles(length(aValsUnique),length(eValsUnique)/2,plotPos,plotGap,plotGap*2,0);
contrastColor = hsv(length(cValsUnique));

for c=1:length(cValsUnique)
%     figure(c);
%     for a = 1:length(aValsUnique)
%         for e = 1:length(eValsUnique)
%         e = a;
        a = 1; e = 2;
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
            locPlotHandle = subplot(2,1,a); 
            hold on;
%             plot(timeVals,dataToAnalyseBLCorrected,'color',[0.5 0.5 0.5],'linewidth',1); hold on;
            plot(timeVals,ERPdata,'color',contrastColor(c,:),'linewidth',1); axis tight; 
            if c==length(cValsUnique)
                legend('0','6.25','12.5','25','50','100'); hold off;
            end
            ylim(locPlotHandle,yLims); xlim(locPlotHandle,xLims); title(['Azimuth: ' num2str(aValsUnique(a)) '; Elevation: ' num2str(eValsUnique(e))]);
            
            % 
            erpPos = (timeVals>erpPeriod(1) & timeVals<=erpPeriod(2));            
            rmsERPdata(c,:) = rms(ERPdata(:,erpPos)) - rms(ERPdata(:,blPos));
%         end
%      end
        
end
    
figure()
scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
% crf1= squeeze(rmsERPdata(1,1,:));
% plot(scaledxaxis,crf1,'o-');hold on
crf2= squeeze(rmsERPdata(1,:));
crf3 = rmsERPdata';
plot(scaledxaxis,crf2,'o-');
plot(scaledxaxis,crf3,'o-');

ax = gca;
ax.XTick = [scaledxaxis];
ax.XTickLabel = {'0','6.25', '12.5', '25', '50', '100'};
% legend('a = -6, e = -6','a = 0, e = 0');
% [parmhat,parmci] = wblfit(crf1);
% A = parmhat(1); B = parmhat(2);
% crf1Fit = wblpdf(scaledxaxis,A,B);
% hold on;
% plot(scaledxaxis,crf1Fit);

wblCDFFcn = @(X,A,B,C)(C-((C-0.5)*(exp(-((X/A).^B)))));

mseCDFFunction = @(YData,XData,params)(sum((YData - wblCDFFcn(XData,params(1),params(2),params(3))).^2));
opts = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',5000,...
    'Display','off','LargeScale','off','MaxFunEvals',5000);
params = fminsearch(@(params)mseCDFFunction(crf3,cValsUnique,params),[0.1   0 5]);
params = [1 0.1];
YFit3 = wblCDFFcn((cValsUnique),abs(params(1)),params(2),params(2));
hold on; plot(scaledxaxis,(YFit3),'g');