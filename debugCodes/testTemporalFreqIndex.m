function [finalResult,testResults] = testTemporalFreqIndex(targetInfo)

testResults = zeros(1,length(targetInfo));

for i=1:length(targetInfo)
    attendLoc = targetInfo(i).attendLoc;
    temporalFreqIndex = targetInfo(i).temporalFreqIndex_stimDesc;
    contrast_stimDesc = targetInfo(i).contrastIndex_stimDesc;
    TF0Hz = targetInfo(i).TF0Hz;
    TF1Hz = targetInfo(i).TF1Hz;
    
    if isnan(temporalFreqIndex)
        if isnan(contrast_stimDesc) && isnan(TF0Hz) && isnan(TF1Hz)
            testResults(i) = 0;
        else
            testResults(i) = 1;
        end
        
    else
        if temporalFreqIndex == 0
            if isequal(TF1Hz,0) && isequal(TF0Hz,0)
                testResults(i) = 0;
            else
                testResults(i) = 1;
            end
        elseif attendLoc == 1 && temporalFreqIndex == 1
            if isequal(TF1Hz,12) && isequal(TF0Hz,16)
                testResults(i) = 0;
            else
                testResults(i) = 1;
            end
        elseif attendLoc == 1 && temporalFreqIndex == 2
            if isequal(TF1Hz,16) && isequal(TF0Hz,12)
                testResults(i) = 0;
            else
                testResults(i) = 1;
            end
        elseif attendLoc == 0 && temporalFreqIndex == 1
            if isequal(TF1Hz,16) && isequal(TF0Hz,12)
                testResults(i) = 0;
            else
                testResults(i) = 1;
            end
        elseif attendLoc == 0 && temporalFreqIndex == 2
            if isequal(TF1Hz,12) && isequal(TF0Hz,16)
                testResults(i) = 0;
            else
                testResults(i) = 1;
            end
        else
            error(['WTF! Parameter Combinations mismatch, attendLoc: ' num2str(attendLoc) ' ,temporalFreqIndex: ' num2str(temporalFreqIndex)])
        end
        
    end
end

finalResult = sum(testResults);

end