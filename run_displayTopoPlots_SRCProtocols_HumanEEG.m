function run_displayTopoPlots_SRCProtocols_HumanEEG
protocolType = 'SRC-Long';
analysisMethodFlag = 1;
plotRawTopoFlag = 0;
subjectIdx = 8:26;

for iEOTCode = 1:2
    displayTopoPlots_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotRawTopoFlag,subjectIdx,iEOTCode,1,'bandPower')
    displayTopoPlots_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotRawTopoFlag,subjectIdx,iEOTCode,2,'bandPower')
    displayTopoPlots_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotRawTopoFlag,subjectIdx,iEOTCode,3,'bandPower')
    
    displayTopoPlots_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotRawTopoFlag,subjectIdx,iEOTCode,2,'SSVEP')
    displayTopoPlots_SRCProtocols_HumanEEG(protocolType,analysisMethodFlag,plotRawTopoFlag,subjectIdx,iEOTCode,3,'SSVEP')
end

end