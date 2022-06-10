

if strcmp(subjectName,'Aritra')
    EEGChannelsExcluded = [1 3 5 6 10 11 14 15 19]; % Aritra:
    EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded);  % unipolar channels Aritra: %[2 12 13 4 16 17 18 7 8 9];
    bipolarEEGChannelsStored(1,:) = [16 16 17 18 18 17  8 8 8]; % Aritra
    bipolarEEGChannelsStored(2,:) = [12  2 16 13  4 18 17 7 9];% Aritra
    EEGChannelsStored{2} = bipolarEEGChannelsStored;
    
elseif strcmp(subjectName,'SVP')
    EEGChannelsExcluded = [1 2 5 8 9 10 11 15 16]; % SVP
    EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded);  % unipolar channels SVP: %[3 4 6 7 12 13 14 7 8 9];
    
    bipolarEEGChannelsStored(1,:) = [12 12 13 14 14 13 18 18 18]; % SVP
    bipolarEEGChannelsStored(2,:) = [ 4  3 12  6  7 12 13 17 19];% ; % SVP
    EEGChannelsStored{2} = bipolarEEGChannelsStored;
    
end