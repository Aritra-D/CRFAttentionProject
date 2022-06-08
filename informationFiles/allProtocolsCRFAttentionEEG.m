function [subjectNames,expDates,protocolNames,stimType,deviceName,capLayout] = allProtocolsCRFAttentionEEG
    jsonFid = fopen('protocol_metadata.json');
    raw = fread(jsonFid, inf);
    jsonText = char(raw');
    protoMetadata = jsondecode(jsonText);
    subjectNames = {protoMetadata.subjectNames};
    expDates = {protoMetadata.expDates};
    protocolNames = {protoMetadata.protocolNames};
    stimType = {protoMetadata.stimType};
    deviceName = {protoMetadata.deviceName};
    capLayout = {protoMetadata.capLayout};
end