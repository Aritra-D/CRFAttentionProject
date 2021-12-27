% Display Single Channel for new SRC protocol

function displaySingleChannelNewSRC(subjectName,expDate,protocolName,folderSourceString,gridType)

if ~exist('folderSourceString','var');   folderSourceString ='E:';      end
if ~exist('gridType','var');             gridType='EEG';                end

folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);

% Get folders
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');

% load LFP Information
[analogChannelsStored,timeVals] = loadlfpInfo(folderLFP);
[neuralChannelsStored,SourceUnitIDs] = loadspikeInfo(folderSpikes);

% Get Combinations
[~,cValsUnique,tValsUnique,eValsUnique,aValsUnique,sValsUnique] = loadParameterCombinations(folderExtract);

% Get properties of the Stimulus
stimResults = loadStimResults(folderExtract);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.25; panelStartHeight = 0.7;
staticPanelWidth = 0.25; staticStartPos = 0.025;
dynamicPanelWidth = 0.25; dynamicStartPos = 0.275;
timingPanelWidth = 0.25; timingStartPos = 0.525;
plotOptionsPanelWidth = 0.2; plotOptionsStartPos = 0.775;
backgroundColor = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dynamic panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynamicHeight = 0.08; dynamicGap=0.02; dynamicTextWidth = 0.6;
hDynamicPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[dynamicStartPos panelStartHeight dynamicPanelWidth panelHeight]);

% Analog channel
analogChannelString = getStringFromValues(analogChannelsStored,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Analog Channel','FontSize',fontSizeSmall);
hAnalogChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analogChannelString,'FontSize',fontSizeSmall);

% Neural channel
neuralChannelString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs);
if ~isempty(neuralChannelsStored)
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
        'Style','text','String','Neural Channel','FontSize',fontSizeSmall);
    hNeuralChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',neuralChannelString,'FontSize',fontSizeSmall);
end
% EOT Codes
EOTCodeString = getEOTCodeString(eValsUnique);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','EOT Code','FontSize',fontSizeSmall);
hEOTCode = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',EOTCodeString,'FontSize',fontSizeSmall);

% Attend Loc
attendLocString = getAttendLocString(aValsUnique);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Attended Location','FontSize',fontSizeSmall);
hAttendLoc = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',attendLocString,'FontSize',fontSizeSmall);

% Stimulus Type
stimTypeString = getStimTypeString(sValsUnique);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Stimulus Type','FontSize',fontSizeSmall);
hStimType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',stimTypeString,'FontSize',fontSizeSmall);

% Analysis Type
analysisTypeString = 'ERP|Firing Rate|Raster|FFT|delta FFT';
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Analysis Type','FontSize',fontSizeSmall);
hAnalysisType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analysisTypeString,'FontSize',fontSizeSmall);

if strcmpi(subjectName,'abu') && strcmpi(gridType,'Microelectrode')
else
    if isfield(stimResults,'orientation')
        staticText = [
            {['Ori(Deg): ' num2str(stimResults.orientation)  ', SF (CPD): ' num2str(stimResults.spatialFrequency)]}; ...
            {['Azi(Deg): ' num2str(stimResults.azimuth) ', Ele (Deg): ' num2str(stimResults.elevation)]}; ...
            {['Si (Deg): ' num2str(stimResults.sigma) ', Rad(Deg): ' num2str(stimResults.radius)]}; ...
            ];
    else
        staticText = [
            {['Ori(Deg): ' num2str(stimResults.baseOrientation0) '/' num2str(stimResults.baseOrientation1)  ', SF (CPD): ' num2str(stimResults.spatialFrequency0) '/' num2str(stimResults.spatialFrequency1)]}; ...
            {['Azi(Deg): ' num2str(stimResults.azimuth0Deg) '/' num2str(stimResults.azimuth1Deg) ', Ele (Deg): ' num2str(stimResults.elevation0Deg) '/' num2str(stimResults.elevation1Deg)]}; ...
            {['Si (Deg): ' num2str(stimResults.sigma) ', Rad(Deg): ' num2str(stimResults.radius)]}; ...
            ];
    end
    
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 0 1 3*dynamicHeight], ..., ...
        'Style','text','String',staticText,'FontSize',fontSizeSmall);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingHeight = 0.1; timingTextWidth = 0.5; timingBoxWidth = 0.25;
hTimingPanel = uipanel('Title','Timing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[timingStartPos panelStartHeight timingPanelWidth panelHeight]);

signalRange = [-0.5 0.75];
fftRange = [0 250];
baseline = [-0.5 0];
stimPeriod = [0.25 0.75];

% Signal Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Parameter','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Min','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth+timingBoxWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Max','FontSize',fontSizeMedium);

% Stim Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim Range (s)','FontSize',fontSizeSmall);
hStimMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeSmall);
hStimMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeSmall);


% FFT Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','FFT Range (Hz)','FontSize',fontSizeSmall);
hFFTMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(1)),'FontSize',fontSizeSmall);
hFFTMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(2)),'FontSize',fontSizeSmall);

% Baseline
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-6*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Basline (s)','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall);
hBaselineMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall);

% Stim Period
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);

% Y Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Y Range','FontSize',fontSizeSmall);
hYMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hYMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotOptionsHeight = 0.1;
hPlotOptionsPanel = uipanel('Title','Plotting Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[plotOptionsStartPos panelStartHeight plotOptionsPanelWidth panelHeight]);

% Button for Plotting
[colorString, colorNames] = getColorString;
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-plotOptionsHeight 0.6 plotOptionsHeight], ...
    'Style','text','String','Color','FontSize',fontSizeSmall);
hChooseColor = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.6 1-plotOptionsHeight 0.4 plotOptionsHeight], ...
    'Style','popup','String',colorString,'FontSize',fontSizeSmall);

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 4*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','cla','FontSize',fontSizeMedium, ...
    'Callback',{@cla_Callback});

hHoldOn = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 3*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','togglebutton','String','hold on','FontSize',fontSizeMedium, ...
    'Callback',{@holdOn_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 2*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale Y','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleY_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale X','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleData_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 0 1 plotOptionsHeight], ...
    'Style','pushbutton','String','plot','FontSize',fontSizeMedium, ...
    'Callback',{@plotData_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get electrode array information
gridLayout = 2; % 8-channel occipital electrodes
electrodeGridPos = [staticStartPos panelStartHeight staticPanelWidth panelHeight];
hElectrodes = showElectrodeLocations(electrodeGridPos,analogChannelsStored(get(hAnalogChannel,'val')), ...
    colorNames(get(hChooseColor,'val')),[],1,0,gridType,subjectName,gridLayout);

% Main plot handles 
startXPos = staticStartPos; startYPos = 0.1; 
if length(tValsUnique)==1
    mainRFWidth = 0.2;
else
    mainRFWidth = 0.85;
end
mainRFHeight = 0.45; gap = 0.002;
stimPlotHeight = 0.05;

numRows = length(cValsUnique); numCols = length(tValsUnique);

showStimGrid = [startXPos startYPos mainRFWidth stimPlotHeight];
plotStimHandles = getPlotHandles(1,numCols,showStimGrid,gap);
gridPos=[startXPos startYPos+2*stimPlotHeight mainRFWidth mainRFHeight]; 
plotHandles = getPlotHandles(numRows+1,numCols,gridPos,gap);

uicontrol('Unit','Normalized','Position',[0 0.975 1 0.025],...
    'Style','text','String',[subjectName expDate protocolName],'FontSize',fontSizeLarge);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)
        e=get(hEOTCode,'val');
        a=get(hAttendLoc,'val');
        s=get(hStimType,'val');
        analysisType = get(hAnalysisType,'val');
        plotColor = colorNames(get(hChooseColor,'val'));
        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
        holdOnState = get(hHoldOn,'val');
        
        if analysisType == 2 || analysisType == 3
            channelPos = get(hNeuralChannel,'val');
            channelNumber = neuralChannelsStored(channelPos);
            unitID = SourceUnitIDs(channelPos);
            plotSpikeData1Channel(plotHandles,channelNumber,e,a,s,folderSpikes,...
                analysisType,timeVals,plotColor,unitID,folderExtract);
        else
            channelNumber = analogChannelsStored(get(hAnalogChannel,'val'));
            plotLFPData1Channel(plotHandles,channelNumber,e,a,s,folderLFP,...
                analysisType,timeVals,plotColor,blRange,stRange,folderExtract);
        end

        if analysisType<=3 % ERP or spikes
            xRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        else
            xRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        end

        yRange = getYLims(plotHandles);
        rescaleData(plotHandles,[xRange yRange]);
        showElectrodeLocations(electrodeGridPos,channelNumber,plotColor,hElectrodes,holdOnState,0,gridType,subjectName,gridLayout);
        
        showTemporalFreqStim(plotStimHandles,tValsUnique);
        yRange = getYLims(plotStimHandles);
        rescaleData(plotStimHandles,[xRange yRange]);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleY_Callback(~,~)

        analysisType = get(hAnalysisType,'val');
        
        if analysisType<=3 % ERP or spikes
            xRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        else
            xRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        end

        yRange = [str2double(get(hYMin,'String')) str2double(get(hYMax,'String'))];
        rescaleData(plotHandles,[xRange yRange]);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleData_Callback(~,~)

        analysisType = get(hAnalysisType,'val');

        if analysisType<=3 % ERP or spikes
            xRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        else
            xRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        end

        yRange = getYLims(plotHandles);
        rescaleData(plotHandles,[xRange yRange]);
        yRange = getYLims(plotStimHandles);
        rescaleData(plotStimHandles,[xRange yRange]);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function holdOn_Callback(source,~)
        holdOnState = get(source,'Value');
        holdOnGivenPlotHandle(plotHandles,holdOnState);
        if holdOnState
            set(hElectrodes,'Nextplot','add');
        else
            set(hElectrodes,'Nextplot','replace');
        end

        function holdOnGivenPlotHandle(plotHandles,holdOnState)
            
            [numRows,numCols] = size(plotHandles);
            if holdOnState
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','add');

                    end
                end
            else
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','replace');
                    end
                end
            end
        end 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        
        claGivenPlotHandle(plotHandles);
        function claGivenPlotHandle(plotHandles)
            [numRows,numCols] = size(plotHandles);
            for i=1:numRows
                for j=1:numCols
                    cla(plotHandles(i,j));
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main function that plots the data
function plotLFPData1Channel(plotHandles,channelNumber,e,a,s,folderLFP,...
analysisType,timeVals,plotColor,blRange,stRange,folderExtract)
titleFontSize = 10;

[parameterCombinations,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);
[numRows,numCols] = size(plotHandles);

% Get appropriate contrast and temporalFreq values
stimResults = loadStimResults(folderExtract);
[~,contrastCellArray] = getContrastString(cValsUnique,stimResults);
[~,temporalFreqCellArray] = getTemporalFreqString(tValsUnique,stimResults);

% Get good Stim Nums
goodStimNums =loadGoodStimNums(folderExtract);

% Get the data
clear signal analogData
load(fullfile(folderLFP,['elec' num2str(channelNumber)]));

% Load bad trials
badTrialFile = fullfile(removeIfPresent(folderLFP,'LFP'),'badTrials.mat');
if exist(badTrialFile,'file')
    load(badTrialFile);
    disp(['Removing ' num2str(length(badTrials)) ' bad stimuli']);
else
    disp('badTrials.mat does not exist');
    badTrials=[];
end

for i=1:numRows-1
    c=i;
    for j=1:numCols
        t=j;
        clear goodPos_stimOnset goodPos_targetOnset
        goodPos_stimOnset = setdiff(parameterCombinations.stimOnset{c,t,e,a,s},badTrials);
        goodPos_targetOnset = setdiff(parameterCombinations.targetOnset{c,t,e,a,s},badTrials);
        
        if isempty(goodPos_stimOnset)
            disp('No entries for this combination..')
        else
            disp([i j length(goodPos_stimOnset)]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Fs = round(1/(timeVals(2)-timeVals(1)));
            blPos = find(timeVals>=blRange(1),1)+ (1:(diff(blRange))*Fs);
            stPos = find(timeVals>=stRange(1),1)+ (1:(diff(stRange))*Fs);

            xsBL = 0:1/(diff(blRange)):Fs-1/(diff(blRange));
            xsST = 0:1/(diff(stRange)):Fs-1/(diff(stRange));
            
            if analysisType == 1        % compute ERP
                clear erp_stimOnset erp_targetOnset
                erp_stimOnset = mean(analogData.stimOnset(goodPos_stimOnset,:),1); %#ok<*NODEF>
                erp_targetOnset = mean(analogData.targetOnset(goodPos_targetOnset,:),1); 
                plot(plotHandles(i,j),timeVals,erp_stimOnset,'color',plotColor);
                plot(plotHandles(i+1,j),timeVals,erp_targetOnset,'color',plotColor); % cValsUnique will always be 100%

            elseif analysisType == 2  ||   analysisType == 3 % compute Firing rates
                disp('Use plotSpikeData instead of plotLFPData...');
            else
                
                fftBL_stimOnset = abs(fft(analogData.stimOnset(goodPos_stimOnset,blPos),[],2));
                fftST_stimOnset = abs(fft(analogData.stimOnset(goodPos_stimOnset,stPos),[],2));
                fftST_targetOnset = abs(fft(analogData.targetOnset(goodPos_targetOnset,blPos),[],2));

                if analysisType == 4
                    plot(plotHandles(i,j),xsBL,log10(mean(fftBL_stimOnset)),'g');
                    set(plotHandles(i,j),'Nextplot','add');
                    plot(plotHandles(i,j),xsBL,log10(mean(fftST_stimOnset)),'k');
                    set(plotHandles(i,j),'Nextplot','replace');
                    plot(plotHandles(i+1,j),xsBL,log10(mean(fftBL_stimOnset)),'g');
                    set(plotHandles(i+1,j),'Nextplot','add');
                    plot(plotHandles(i+1,j),xsST,log10(mean(fftST_targetOnset)),'k');
                    set(plotHandles(i+1,j),'Nextplot','replace');
                end

                if analysisType == 5
                    if xsBL == xsST %#ok<BDSCI>
                        plot(plotHandles(i,j),xsBL,log10(mean(fftST))-log10(mean(fftBL)),'color',plotColor);
                    else
                        disp('Choose same baseline and stimulus periods..');
                    end
                end
            end
            
            % Display title
            if (i==1)
                if (j==1)
                    title(plotHandles(i,j),['TF(Hz): ' temporalFreqCellArray(t)],'FontSize',titleFontSize);
                else
                    title(plotHandles(i,j),temporalFreqCellArray(t),'FontSize',titleFontSize); hold(plotHandles(i,j),'on'); 
                end
            end
                
            if (j==numCols)
                if (i==1)
                 ylabel(plotHandles(i,j),['CON(%): ' contrastCellArray(c)],'FontSize',titleFontSize,...
                     'Units','Normalized','Rotation',0,'FontWeight','bold','Position',[1.25 0.5]);
                else
                    title(plotHandles(i,j),contrastCellArray(c),'FontSize',titleFontSize,...
                     'Units','Normalized','Position',[1.25 0.5]);
                end
            end
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSpikeData1Channel(plotHandles,channelNumber,e,a,s,folderSpikes,...
analysisType,timeVals,plotColor,unitID,folderExtract)
titleFontSize = 12;

[parameterCombinations,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);
[numRows,numCols] = size(plotHandles);

% Get the data
clear signal spikeData
load(fullfile(folderSpikes,['elec' num2str(channelNumber) '_SID' num2str(unitID)]));

for i=1:numRows
    c = i;
    for j=1:numCols
        t = j;
        clear goodPos
        goodPos = parameterCombinations{c,t,e,a,s};

        if isempty(goodPos)
            disp('No entries for this combination..')
        else
            disp([i j length(goodPos)]);
            
            if analysisType == 2
                [psthVals,xs] = psth_SR(spikeData(goodPos),10,timeVals(1),timeVals(end));
                plot(plotHandles(i,j),xs,psthVals,'color',plotColor);
            else
                X = spikeData(goodPos);
                axes(plotHandles(i,j)); %#ok<LAXES>
                rasterplot(X,1:length(X),plotColor);
            end
        end
        
        % Display title
        if (i==1)
            if (j==1)
                title(plotHandles(i,j),['TF(Hz): ' getTemporalFreqString(tValsUnique(t))],'FontSize',titleFontSize);
            else
                title(plotHandles(i,j),getTemporalFreqString(tValsUnique(t)),'FontSize',titleFontSize);
            end
        end

        if (j==numCols)
            if (i==1)
                title(plotHandles(i,j),[{'Con(%)'} {getContrastString(cValsUnique(c))}],'FontSize',titleFontSize,...
                    'Units','Normalized','Position',[1.25 0.5]);
            else
                title(plotHandles(i,j),getContrastString(cValsUnique(c)),'FontSize',titleFontSize,...
                    'Units','Normalized','Position',[1.25 0.5]);
            end
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yRange = getYLims(plotHandles)

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
yRange = [yMin yMax];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rescaleData(plotHandles,axisLims)

[numRows,numCols] = size(plotHandles);
labelSize=12;
for i=1:numRows
    for j=1:numCols
        axis(plotHandles(i,j),axisLims);
        if (i==numRows && rem(j,2)==1)
            if j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
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
function outString = getStringFromValues(valsUnique,decimationFactor)

if length(valsUnique)==1
    outString = convertNumToStr(valsUnique(1),decimationFactor);
else
    outString='';
    for i=1:length(valsUnique)
        outString = cat(2,outString,[convertNumToStr(valsUnique(i),decimationFactor) '|']);
    end
    outString = [outString 'all'];
end

    function str = convertNumToStr(num,f)
        if num > 16384
            num=num-32768;
        end
        str = num2str(num/f);
    end
end
function outString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs)
outString='';
for i=1:length(neuralChannelsStored)
    outString = cat(2,outString,[num2str(neuralChannelsStored(i)) ', SID ' num2str(SourceUnitIDs(i)) '|']);
end 
end
function [contrastString,contrastCellArray] = getContrastString(cIndexValsUnique,stimResults)

contrastCellArray = [];
if isfield(stimResults,'contrast0PC')
    [cVals0Unique,cVals1Unique] = getValsFromIndex(cIndexValsUnique,stimResults,'contrast');
    if length(cVals0Unique)==1
        contrastCellArray{1} = [num2str(cVals0Unique) ',' num2str(cVals1Unique)];
        contrastString = contrastCellArray{1};
    else
        contrastString = '';
        for i=1:length(cVals0Unique)
            contrastCellArray{i} = [num2str(cVals0Unique(i)) ',' num2str(cVals1Unique(i))];
            contrastString = cat(2,contrastString,[contrastCellArray{i} '|']);
        end
        contrastString = [contrastString 'all'];
    end
    
else % Work with indices
    if length(cIndexValsUnique)==1
        if cIndexValsUnique ==0
            contrastString = '0';
        else
            contrastString = num2str(100/2^(7-cIndexValsUnique));
        end
        
    else
        contrastString = '';
        for i=1:length(cIndexValsUnique)
            if cIndexValsUnique(i) == 0
                contrastString = cat(2,contrastString,[ '0|']); %#ok<*NBRAK>
            else
                contrastString = cat(2,contrastString,[num2str(100/2^(7-cIndexValsUnique(i))) '|']);
            end
        end
        contrastString = [contrastString 'all'];
    end
end
end
function [temporalFreqString,temporalFreqCellArray] = getTemporalFreqString(tIndexValsUnique,stimResults)

temporalFreqCellArray = [];
if isfield(stimResults,'temporalFreq0Hz')
    [tVals0Unique,tVals1Unique] = getValsFromIndex(tIndexValsUnique,stimResults,'temporalFreq');
    if length(tIndexValsUnique)==1
        temporalFreqCellArray{1} = [num2str(tVals0Unique) ',' num2str(tVals1Unique)];
        temporalFreqString = temporalFreqCellArray{1};
    else
        temporalFreqString = '';
        for i=1:length(tIndexValsUnique)
            temporalFreqCellArray{i} = [num2str(tVals0Unique(i)) ',' num2str(tVals1Unique(i))]; %#ok<*AGROW>
            temporalFreqString = cat(2,temporalFreqString,[temporalFreqCellArray{i} '|']);
        end
        temporalFreqString = [temporalFreqString 'all'];
    end
else
    if length(tIndexValsUnique)==1
        if tIndexValsUnique ==0
            temporalFreqString = '0';
        else
            temporalFreqString = num2str(min(50,80/2^(7-tIndexValsUnique)));
        end
        
    else
        temporalFreqString = '';
        for i=1:length(tIndexValsUnique)
            if tIndexValsUnique(i) == 0
                temporalFreqString = cat(2,temporalFreqString,[ '0|']);
            else
                temporalFreqString = cat(2,temporalFreqString,[num2str(min(50,80/2^(7-tIndexValsUnique(i)))) '|']);
            end
        end
        temporalFreqString = [temporalFreqString 'all'];
    end
end
end
function EOTCodeString = getEOTCodeString(eValsUnique)

if length(eValsUnique)==1
    if eValsUnique == 0
        EOTCodeString = 'Correct';
    elseif eValsUnique == 1
        EOTCodeString = 'Wrong';
    elseif eValsUnique == 2
        EOTCodeString = 'Failed';
    elseif eValsUnique == 3
        EOTCodeString = 'Broke';
    elseif eValsUnique == 4
        EOTCodeString = 'Ignored';
    elseif eValsUnique == 5
        EOTCodeString = 'False Alarm';
    elseif eValsUnique == 6
        EOTCodeString = 'Distracted';
    elseif eValsUnique == 7
        EOTCodeString = 'Force Quit';
    else
        disp('Unknown EOT Code');
    end
else
    EOTCodeString = '';
    for i=1:length(eValsUnique)
        if eValsUnique(i) == 0
            EOTCodeString = cat(2,EOTCodeString,['Correct|']);
        elseif eValsUnique(i) == 1
            EOTCodeString = cat(2,EOTCodeString,['Wrong|']);
        elseif eValsUnique(i) == 2
            EOTCodeString = cat(2,EOTCodeString,['Failed|']);
        elseif eValsUnique(i) == 3
            EOTCodeString = cat(2,EOTCodeString,['Broke|']);
        elseif eValsUnique(i) == 4
            EOTCodeString = cat(2,EOTCodeString,['Ignored|']);
        elseif eValsUnique(i) == 5
            EOTCodeString = cat(2,EOTCodeString,['False Alarm|']);
        elseif eValsUnique(i) == 6
            EOTCodeString = cat(2,EOTCodeString,['Distracted|']);
        elseif eValsUnique(i) == 7
            EOTCodeString = cat(2,EOTCodeString,['Force Quit|']);
        else
            disp('Unknown EOT Code');
        end
    end
    EOTCodeString = [EOTCodeString 'all'];
end
end
function attendLocString = getAttendLocString(aValsUnique)

if length(aValsUnique)==1
    if aValsUnique == 0
        attendLocString = '0 (outside)';
    elseif aValsUnique == 1
        attendLocString = '1 (inside)';
    else
        disp('Unknown attended location');
    end
else
    attendLocString = '';
    for i=1:length(aValsUnique)
        if aValsUnique(i) == 0
            attendLocString = cat(2,attendLocString,['0 (outside)|']);
        elseif aValsUnique(i) == 1
            attendLocString = cat(2,attendLocString,['1 (inside)|']);
        else
            disp('Unknown attended location');
        end
    end
    attendLocString = [attendLocString 'Both'];
end
end
function stimTypeString = getStimTypeString(sValsUnique)

if length(sValsUnique)==1
    if sValsUnique == 0
        stimTypeString = 'Null';
    elseif sValsUnique == 1
        stimTypeString = 'Correct';
    elseif sValsUnique == 2
        stimTypeString = 'Target';
    elseif sValsUnique == 3
        stimTypeString = 'FrontPad';
    elseif sValsUnique == 4
        stimTypeString = 'BackPad';
    else
        disp('Unknown Stimulus Type');
    end
else
    stimTypeString = '';
    for i=1:length(sValsUnique)
        if sValsUnique(i) == 0
            stimTypeString = cat(2,stimTypeString,['Null|']);
        elseif sValsUnique(i) == 1
            stimTypeString = cat(2,stimTypeString,['Correct|']);
        elseif sValsUnique(i) == 2
            stimTypeString = cat(2,stimTypeString,['Target|']);
        elseif sValsUnique(i) == 3
            stimTypeString = cat(2,stimTypeString,['FrontPad|']);
        elseif sValsUnique(i) == 4
            stimTypeString = cat(2,stimTypeString,['BackPad|']);
        else
            disp('Unknown Stimulus Type');
        end
    end
    stimTypeString = [stimTypeString 'all'];
end

end
function [colorString, colorNames] = getColorString
colorNames = 'brkgcmy';
colorString = 'blue|red|black|green|cyan|magenta|yellow';
end
function [valList0Unique,valList1Unique] = getValsFromIndex(indexListUnique,stimResults,fieldName)
if isfield(stimResults,[fieldName 'Index'])
    
    indexList = getfield(stimResults,[fieldName 'Index']); %#ok<*GFLD>
    if strcmpi(fieldName,'contrast')
        valList0 = getfield(stimResults,[fieldName '0PC']);
        valList1 = getfield(stimResults,[fieldName '1PC']);
    else
        valList0 = getfield(stimResults,[fieldName '0Hz']);
        valList1 = getfield(stimResults,[fieldName '1Hz']);
    end
    
    numList = length(indexListUnique);
    valList0Unique = zeros(1,numList);
    valList1Unique = zeros(1,numList);
    for i=1:numList
        valList0Unique(i) = unique(valList0(indexListUnique(i)==indexList));
        valList1Unique(i) = unique(valList1(indexListUnique(i)==indexList));
    end
else
    valList0Unique = indexListUnique;
    valList1Unique = indexListUnique;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
function [analogChannelsStored,timeVals,goodStimPos] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo'));
end
function [neuralChannelsStored,SourceUnitID] = loadspikeInfo(folderSpikes)
fileName = fullfile(folderSpikes,'spikeInfo.mat');
if exist(fileName,'file')
    load(fileName);
else
    neuralChannelsStored=[];
    SourceUnitID=[];
end
end
function [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,...
    aValsUnique,sValsUnique] = loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat'));
end
function stimResults = loadStimResults(folderExtract)
load (fullfile(folderExtract,'stimResults'));
end
function goodStimNums =loadGoodStimNums(folderExtract)
load(fullfile(folderExtract,'goodStimNums'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showTemporalFreqStim(plotStimHandles,tValsUnique)

%frameStim = 0:19;
tBefore = [-600:10:-10]/1000; beforePad = zeros(1,length(tBefore));
tStim   =  [0:10:400]/1000;
tAfter  = [410:10:900]/1000; afterPad = zeros(1,length(tAfter));

timeInSec = [tBefore tStim tAfter];


numCols = length(plotStimHandles);

for i=1:numCols
    tf = tValsUnique(i);
    
    if tf==0
        tempFreq=0;
    else
        tempFreq = min(50,80/2^(7-tf));
    end
    
    if tempFreq==50
        tempPhase = pi/2;
    else
        tempPhase = 0;
    end

    if tf==0
        stimVal = [beforePad ones(1,length(tStim)) afterPad];
    else
        stimVal = [beforePad sin(2*pi*tempFreq*tStim+tempPhase) afterPad];
    end
    
    plot(plotStimHandles(i),timeInSec,stimVal,'k');
%     set(plotStimHandles(i),'Nextplot','add');
%     plot(plotStimHandles(i),timeInSec,stimVal,'ko');
end
end