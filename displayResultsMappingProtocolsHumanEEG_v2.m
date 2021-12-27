function displayResultsMappingProtocolsHumanEEG_v2(subjectName,expDate,protocolIDs,folderSourceString,gridType,sideChoice,analysisType,tapers_MT,stimType,plotPSDFlag,displayDeltaPSDFlag)

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

close all;

[subjectNames_all,expDates_all,protocolNames_all,~,~,~] = allProtocolsCRFAttentionEEG;
% protocolIDs = find(strcmp(subjectName,subjectNames_all)& strcmp(expDate,expDates_all)); % only SubjectName is
% 
% expDates = expDates_all(protocolIDs(initMappingProtocolIndex:initMappingProtocolIndex+3));
% protocolNames = protocolNames_all(protocolIDs(initMappingProtocolIndex:initMappingProtocolIndex+3));
% num_protocols = 4;

expDates = expDates_all(protocolIDs);
protocolNames = protocolNames_all(protocolIDs);
% deviceName = deviceName(protocolIDs(end));
% capLayout = capLayout(protocolIDs(end));
num_protocols = length(protocolIDs);

% Display Properties
hFig = figure();
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlotsFig.hPlot1 = getPlotHandles(2,1,[0.7 0.1 0.25 0.8],0.01,0.01,1);
hPlotsFig.hPlot2 = getPlotHandles(4,num_protocols,[0.08 0.1 0.55 0.8],0.01,0.01,1); linkaxes

blRange = [-0.5 0];
stRange = [0.25 0.75];

freqRanges{1} = [8 12]; % alpha
freqRanges{2} = [32 80]; % gamma
freqRanges{3} = [104 248]; % hi-gamma
freqRanges{4} = [16 16];  % SSVEP
numFreqs = length(freqRanges);

for iRefScheme = 1:2
    %%
    clear fftBL fftST powerValsBL powerValsST
    for iProt = 1:num_protocols
        clear lfpInfo folderName unipolarEEGChannelsStored bipolarEEGChannelsStored
        disp(['Processing data for Protocol: ' num2str(iProt) ' : expDate' expDates{iProt} ' : protocolName' protocolNames{iProt}])
        folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDates{iProt},protocolNames{iProt});
        folderExtract = fullfile(folderName,'extractedData');
        folderSegment= fullfile(folderName,'segmentedData');
        folderLFP = fullfile(folderName,'segmentedData','LFP');
        lfpInfo = load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
        
        
        Fs = round(1/(lfpInfo.timeVals(2)-lfpInfo.timeVals(1)));
        if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
            disp('baseline and stimulus ranges are not the same');
        else
            range = blRange;
            rangePos = round(diff(range)*Fs);
            blPos = find(lfpInfo.timeVals>=blRange(1),1)+ (1:rangePos);
            stPos = find(lfpInfo.timeVals>=stRange(1),1)+ (1:rangePos);
            if strcmp(analysisType,'FFT')
                freqVals = 0:1/diff(range):Fs-1/diff(range);
            end
        end
        

        
        if strcmp(subjectName,'Aritra') % 19- channel Layout with a problematic Physical channels arrangement, exp: 120221
            photoDiodeIDs = [20 21];
            unipolarEEGChannelsStored = setdiff(lfpInfo.analogChannelsStored,photoDiodeIDs);
            EEGChannelsExcluded = [1 3 5 6 10 11 14 15 19]; % Aritra:
            EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded);  % unipolar channels Aritra: %[2 12 13 4 16 17 18 7 8 9];
            bipolarEEGChannelsStored(1,:) = [16 16 17 18 18 17  8 8 8]; % Aritra
            bipolarEEGChannelsStored(2,:) = [12  2 16 13  4 18 17 7 9];% Aritra
            EEGChannelsStored{2} = bipolarEEGChannelsStored;
            
        elseif strcmp(subjectName,'SVP') % 19- channel Layout covering all Parieto-occipital and Occipital electrodes
            photoDiodeIDs = [20 21];
            unipolarEEGChannelsStored = setdiff(lfpInfo.analogChannelsStored,photoDiodeIDs);
            if sideChoice == 0
                EEGChannelsExcluded = [1 2 5 8 9 10 11 15 16]; % SVP
                EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded);  % unipolar channels SVP: %[3 4 6 7 12 13 14 7 8 9];
                
                bipolarEEGChannelsStored(1,:) = [12 12 13 14 14 13 18 18 18]; % SVP
                bipolarEEGChannelsStored(2,:) = [ 4  3 12  6  7 12 13 17 19];% ; % SVP
                EEGChannelsStored{2} = bipolarEEGChannelsStored;
                
            elseif sideChoice == 1
                EEGChannelsLeft = [3 4 12 17];
                EEGChannelsStored{1} = EEGChannelsLeft;
                
                bipolarEEGChannelsStored(1,:) = [12 12 13 ]; % SVP
                bipolarEEGChannelsStored(2,:) = [ 4  3 12 ];% ; % SVP
                EEGChannelsStored{2} = bipolarEEGChannelsStored;
                
            elseif sideChoice == 2
                EEGChannelsRight = [6 7 14 19];
                EEGChannelsStored{1} = EEGChannelsRight;
                
                bipolarEEGChannelsStored(1,:) = [14 14 13 ]; % SVP
                bipolarEEGChannelsStored(2,:) = [ 6  7 12 ];% ; % SVP
                EEGChannelsStored{2} = bipolarEEGChannelsStored;
            end
            
        else % 64-Channel Standard Acticap Layout
            photoDiodeIDs = [65 66];
            % Get bad trials
            badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
            if ~exist(badTrialFile,'file')
                disp('Bad trial file does not exist...');
                badElecs = []; badTrials=[];
            else
                [badTrials,badElecs] = loadBadTrials(badTrialFile);
                badElecsAll = unique([badElecs.badImpedanceElecs; badElecs.noisyElecs; badElecs.flatPSDElecs; badElecs.flatPSDElecs]);
                disp([num2str(length(badTrials)) ' bad trials']);
                disp([num2str(length(badElecsAll)) ' bad elecs']);
            end
            unipolarEEGChannelsStored = setdiff(lfpInfo.analogChannelsStored,photoDiodeIDs);
            if sideChoice == 0
                % UnipolarEEGChannelLabels =    [P3     P1      P2      P4      PO3     POz     PO4     O1      Oz      O2];
                EEGChannelsStored{1} =          [24     57      58      26      61      62      63      29      30      31]; % Unipolar Electrodes
                %(This numbers can also be verified from  in CommonPrograms\ReadMontages\getHighPriorityElectrodes)

                % bipolarEEGChannelLabels1 =    [PO3    PO3     POz     PO4     PO4     POz     Oz      Oz      Oz]
                % bipolarEEGChannelLabels2 =    [P1     P3      PO3     P2      P4      PO4     POz     O1      O2]
                bipolarEEGChannelsStored(1,:) = [61     61      62      63      63      62      30      30      30];
                bipolarEEGChannelsStored(2,:) = [57     24      61      58      26      63      62      29      31];

                
            elseif sideChoice == 1
                EEGChannelsLeft = [65];
                EEGChannelsStored{1} = EEGChannelsLeft;
                
                bipolarEEGChannelsStored(1,:) = [61 61 62];
                bipolarEEGChannelsStored(2,:) = [57  24 61];

                
            elseif sideChoice == 2
                EEGChannelsRight = [66];
                EEGChannelsStored{1} = EEGChannelsRight;
                
                bipolarEEGChannelsStored(1,:) = [63 63 62];
                bipolarEEGChannelsStored(2,:) = [58 26 63];

            end
            
            EEGChannelsStored{1} = setdiff(EEGChannelsStored{1},badElecsAll);% Unipolar Electrodes
            badIDs = [];
            for i= 1:length(badElecsAll)
                badIDs = unique(cat(2,badIDs,find(badElecsAll(i) == bipolarEEGChannelsStored(1,:) | badElecsAll(i) == bipolarEEGChannelsStored(2,:))));
            end
            bipolarEEGChannelsStored(:,badIDs) = [];
            EEGChannelsStored{2} = bipolarEEGChannelsStored;% Bipolar Electrodes
        end
        
        
        [parameterCombinations,parameterCombinations2,aValsUnique,aValsUnique2,eValsUnique,eValsUnique2,...
            sValsUnique,sValsUnique2,~,~,~,~,~,~,tValsUnique,tValsUnique2] = loadParameterCombinations(folderExtract); %#ok<*ASGLU>
        
        if iRefScheme ==1
            if unique(aValsUnique) == -unique(aValsUnique2)
                aziVal(iProt) = aValsUnique2;
            else
                error('aziVals are not equidistant')
            end
            
            if unique(eValsUnique) == unique(eValsUnique2)
                eleVal(iProt) = -eValsUnique2;
            else
                error('eleVals are not in same hemifield')
            end
            
            if unique(sValsUnique) == unique(sValsUnique2)
                sigmaVal = sValsUnique2;
                radiusToSigmaRatio = 3;
                diameterVal(iProt) = round(2*radiusToSigmaRatio*sigmaVal);
            else
                error('stim size are not equal')
            end
        end
        
            
        
        a1=1; a2=1; e1=1; e2=1; s1=1; s2=1; sf1=1; sf2=1;
        o1=1; o2=1; c1 =1; c2=1;
        tList=1:length(tValsUnique);
%         
%         % Get bad trials
%         badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
%         if ~exist(badTrialFile,'file')
%             disp('Bad trial file does not exist...');
%             badTrials=[];
%         else
%             badTrials = loadBadTrials(badTrialFile);
%             disp([num2str(length(badTrials)) ' bad trials']);
%         end
        
        % Main loop for data processing for different parameter
        % combinations
        for iElec = 1:size(EEGChannelsStored{iRefScheme},2)
            clear x
            if iRefScheme == 1
                clear x
                disp(['Processing electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(iElec))])
                x = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(iElec)) '.mat']));
            elseif iRefScheme == 2
                clear x1 x2 x
                disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) ' - ' num2str(EEGChannelsStored{iRefScheme}(2,iElec))])
                x1 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) '.mat']));
                x2 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(2,iElec)) '.mat']));
                x.analogData = x1.analogData-x2.analogData;
            end
            
            % loop for parameter combinations
            for iTF = 1:2
                clear goodPos
                goodPos1 = parameterCombinations{a1,e1,s1,sf1,o1,c1,iTF};
                goodPos2 = parameterCombinations2{a2,e2,s2,sf2,o2,c2,iTF};
                goodPos = intersect(goodPos1,goodPos2);
                goodPos = setdiff(goodPos,badTrials);
                
                if isempty(goodPos)
                    disp(['No entries for this combination.. iProt == ' num2str(iProt) ' TF ==' num2str(iTF)]);
                else
                    if strcmp(analysisType,'FFT')
                        fftBL(iProt,iElec,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                        fftST(iProt,iElec,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,stPos),[],2)))));
                    elseif strcmp(analysisType,'MT')
                        
                        % Set up params for MT
                        params.tapers   = tapers_MT;
                        params.pad      = -1;
                        params.Fs       = Fs;
                        params.fpass    = [0 250];
                        params.trialave = 1;
                        
                        % Set up movingWindow parameters for time-frequency plot
                        winSize = 0.1;
                        winStep = 0.025;
                        movingwin = [winSize winStep];
                        
                        % PSD
                        [tmpEBL,freqValsBL] = mtspectrumc(x.analogData(goodPos,blPos)',params);
                        [tmpEST,freqValsST] = mtspectrumc(x.analogData(goodPos,stPos)',params);
                        if isequal(freqValsBL,freqValsST)
                            freqVals = freqValsST;
                        end
                        psdBL(iProt,iElec,iTF,:) = conv2Log(tmpEBL);
                        psdST(iProt,iElec,iTF,:) = conv2Log(tmpEST);
                        
                        if iTF ==1
                            for i=1:numFreqs-1
                                powerValsBL{i}(iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{i}));
                                powerValsST{i}(iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{i}));
                            end
                        elseif iTF ==2
                            powerValsBL{numFreqs}(iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{numFreqs}));
                            powerValsST{numFreqs}(iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{numFreqs}));
                        end
                        
                        % TF
                        % computing time-frequency spectrum by
                        % multi-taper method (computed for both static
                        % and counterphase stimuli)
                        [tmpE_tf,tmpT_tf,freqVals_tf] = mtspecgramc(x.analogData(goodPos,:)',movingwin,params);
                        
                        timeVals_tf_= tmpT_tf + lfpInfo.timeVals(1);
                        energy_tf = conv2Log(tmpE_tf)';
                        energyBL_tf = mean(energy_tf(:,timeVals_tf_>=blRange(1)& timeVals_tf_<=blRange(2)),2);
                        
                        mEnergy_tf(iProt,iElec,iTF,:,:) = energy_tf;
                        mEnergyBL_tf(iProt,iElec,iTF,:,:) = repmat(energyBL_tf,1,length(timeVals_tf_));
                        
                        
                    end
                end
            end
        end
    end
    
    
    if strcmp(analysisType,'FFT')
        fftBL_all{iRefScheme} = fftBL;
        fftST_all{iRefScheme} = fftST;
    elseif strcmp(analysisType,'MT')
        psdBL_all{iRefScheme} = psdBL;
        psdST_all{iRefScheme} = psdST;
        powerValsBL_all{iRefScheme} = powerValsBL;
        powerValsST_all{iRefScheme} = powerValsST;
        
        tfData_all{iRefScheme} = mEnergy_tf;
        tfDataBL_all{iRefScheme} = mEnergyBL_tf;
        tfData.timeVals = timeVals_tf_;
        tfData.freqVals = freqVals_tf;
        
    end
end

freqLims = [0 100];

colors = [0, 0.4470,0.7410;... % Dark Sky Blue
    0,  0.75, 0.75;...    %  Teal
    0.9290, 0.6940, 0.1250;... % Yellow Ochre
    0.8500 0.3250 0.0980;...
    1 0 0;...
    0.6350 0.0780, 0.1840;...
    0.4940, 0.1840, 0.5560
    0, 1, 1;
    1, 0,1];
% Burgandy %jet(length(oValsUnique));

if strcmp(analysisType,'FFT')
    dataBL = fftBL_all;
    dataST = fftST_all;
elseif strcmp(analysisType,'MT')
    dataBL = psdBL_all;
    dataST = psdST_all;
end
% plotting
for iRefScheme = 1:2
    for iProt = 1:num_protocols
        %         yyaxis left % hPlotsFig.hPlot2(iRefScheme,iProt)
        if plotPSDFlag
            plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,squeeze(mean(dataBL{iRefScheme}(iProt,:,1,:),2)),'-k','LineWidth', 1.5); hold (hPlotsFig.hPlot2(iRefScheme,iProt),'on')
            plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,squeeze(mean(dataST{iRefScheme}(iProt,:,1,:),2)),'color',colors(iProt,:,:),'LineWidth', 1.5);
        end
        if strcmp(analysisType,'MT')&& displayDeltaPSDFlag
            plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,10*(squeeze(mean(dataBL{iRefScheme}(iProt,:,1,:),2)-mean(dataBL{iRefScheme}(iProt,:,1,:),2))),'-k','LineWidth', 1.5);hold (hPlotsFig.hPlot2(iRefScheme,iProt),'on')
            plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,10*(squeeze(mean(dataST{iRefScheme}(iProt,:,1,:),2)-mean(dataBL{iRefScheme}(iProt,:,1,:),2))),'-b','LineWidth', 1.5);
        end
        xlim(hPlotsFig.hPlot2(iRefScheme,iProt),freqLims); ylim(hPlotsFig.hPlot2(iRefScheme,iProt),[1.8 4.2]);
        
        %         yyaxis right
        %         yyaxis(hPlotsFig.hPlot2(iRefScheme,iProt),'right')
        %         clear dffT
        %         dffT_dB = 20*(squeeze(mean(fftST_all{iRefScheme}(iProt,:,1,:),2)) - squeeze(mean(fftBL_all{iRefScheme}(iProt,:,1,:),2)));
        %         plot(hPlotsFig.hPlot2(iRefScheme,iProt),xs,dffT,'-b','LineWidth', 1.5);
        if plotPSDFlag
            plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,squeeze(mean(dataBL{iRefScheme}(iProt,:,2,:),2)),'-k','LineWidth', 1.5);hold (hPlotsFig.hPlot2(iRefScheme+2,iProt),'on')
            plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,squeeze(mean(dataST{iRefScheme}(iProt,:,2,:),2)),'color',colors(iProt,:,:),'LineWidth', 1.5);
        end
        if strcmp(analysisType,'MT')&& displayDeltaPSDFlag
            plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,10*(squeeze(mean(dataBL{iRefScheme}(iProt,:,2,:),2)-mean(dataBL{iRefScheme}(iProt,:,2,:),2))),'-k','LineWidth', 1.5);hold (hPlotsFig.hPlot2(iRefScheme+2,iProt),'on')
            plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,10*(squeeze(mean(dataST{iRefScheme}(iProt,:,2,:),2)-mean(dataBL{iRefScheme}(iProt,:,2,:),2))),'-b','LineWidth', 1.5);
        end
        xlim(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqLims); ylim(hPlotsFig.hPlot2(iRefScheme+2,iProt),[1.8 4.2]);
    end
end

% displayRange(hPlotsFig.hPlot1(1:2,:),[8 12],getYLims(hPlotsFig.hPlot1),[0.25 0.25 0.25],'solid-solid')
displayRange(hPlotsFig.hPlot2(1:2,:),[20 34],getYLims(hPlotsFig.hPlot2),[0.75 0 0.75],'solid-solid')
displayRange(hPlotsFig.hPlot2(1:2,:),[36 66],getYLims(hPlotsFig.hPlot2),[0.9290 0.6940 0.1250],'dash-dash')

displayRange(hPlotsFig.hPlot2(3:4,:),[24 24],getYLims(hPlotsFig.hPlot2),[0.25 0.25 0.25],'solid-solid')
displayRange(hPlotsFig.hPlot2(3:4,:),[32 32],getYLims(hPlotsFig.hPlot2),[0.5 0.5 0.5],'solid-solid')

rescaleData(hPlotsFig.hPlot2,0,100,getYLims(hPlotsFig.hPlot2),14);
% ylim(hPlotsFig.hPlot2(1,1),[1.5 4.2]);


for iProt=1:num_protocols
    title(hPlotsFig.hPlot2(1,iProt),[{['a = ' num2str(aziVal(iProt),2), char (176), ', e = ' num2str(eleVal(iProt),2), char (176)]},{ ['d = ' num2str(diameterVal(iProt)) char(176)]}],'fontSize',10)
end

ylabel(hPlotsFig.hPlot2(1,1),{'Unipolar PSD','static'})
ylabel(hPlotsFig.hPlot2(2,1),{'Bipolar PSD','static'})

ylabel(hPlotsFig.hPlot2(3,1),{'Unipolar PSD','Flicker'})
ylabel(hPlotsFig.hPlot2(4,1),{'Bipolar PSD','Flicker'})

xlabel(hPlotsFig.hPlot2(4,1),'Frequency (Hz)')

if iRefScheme == 1
    if strcmp(analysisType,'MT')
        figName = fullfile(folderSourceString,'MappingProtocols',stimType,[subjectName, expDate, '_sideChoice_' num2str(sideChoice) '_Unipolar_Ref_tapers', num2str(tapers_MT(2)) '_plotPSDFlag' num2str(plotPSDFlag) '_displayDeltaPSDs' num2str(displayDeltaPSDFlag)]);
    else
        figName = fullfile(folderSourceString,'MappingProtocols',stimType,[subjectName, expDate, '_sideChoice_' num2str(sideChoice) '_Unipolar_Ref_tapers', 'FFT plots']);
    end
    
elseif iRefScheme == 2
    if strcmp(analysisType,'MT')
        figName = fullfile(folderSourceString,'MappingProtocols',stimType,[subjectName, expDate, '_sideChoice_' num2str(sideChoice) '_Bipolar_Ref_tapers', num2str(tapers_MT(2)) '_plotPSDFlag' num2str(plotPSDFlag) '_displayDeltaPSDs' num2str(displayDeltaPSDFlag)]);
    else
        figName = fullfile(folderSourceString,'MappingProtocols',stimType,[subjectName, expDate, '_sideChoice_' num2str(sideChoice) '_Bipolar_Ref_', 'FFT plots']);
    end
end

saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')
end


%% Accessory Functions
% function [analogChannelsStored,goodStimPos,timeVals,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
% load(fullfile(folderLFP,'lfpInfo.mat'));
% if ~exist('analogInputNums','var')
%     analogInputNums=[];
% end
% end
% load Parameter combinations
function [parameterCombinations,parameterCombinations2,...
    aValsUnique,aValsUnique2,eValsUnique,eValsUnique2,...
    sValsUnique,sValsUnique2,fValsUnique,fValsUnique2,...
    oValsUnique,oValsUnique2,cValsUnique,cValsUnique2,...
    tValsUnique,tValsUnique2] = loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>

if ~exist('sValsUnique','var');    sValsUnique = rValsUnique/3;         end
if ~exist('cValsUnique','var');    cValsUnique=[];                      end
if ~exist('tValsUnique','var');    tValsUnique=[];                      end
end


function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

% Draw lines for timeTange or FreqRange
function displayRange(plotHandles,range,yLims,colorName,lineStyle)
[nX,nY] = size(plotHandles);
% yLims = getYLims(plotHandles);
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
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineWidth',1.5);
        elseif strcmp(lineStyle,'dash-dash')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
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
% function index = getClosestIndex(xs,val)
% xs2 = abs(xs-val);
% index = find(xs2==min(xs2),1);
% end
% function [freqPosToRemove,frequenciesToRemove] = getFreqPosToRemove(freq)
% 
% frequenciesToRemove = [58 62; 98 102; 118 122; 238 242];
% 
% N = size(frequenciesToRemove,1);
% freqPosToRemove=[];
% for i=1:N
%     freqPosToRemove = cat(2,freqPosToRemove,getClosestIndex(freq,frequenciesToRemove(i,1)):getClosestIndex(freq,frequenciesToRemove(i,2)));
% end
% end
% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)

posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
eValue   = sum(mEnergy(posToAverage));
end
% Rescale data
function rescaleData(plotHandles,xMin,xMax,yLims,labelSize)

[numRows,numCols] = size(plotHandles);
% labelSize=14;
for i=1:numRows
    for j=1:numCols
        hold(plotHandles(i,j),'on');
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && rem(j,2)==1)
            if j==1
                set(plotHandles(i,j),'fontSize',labelSize);
            elseif j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==0 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%