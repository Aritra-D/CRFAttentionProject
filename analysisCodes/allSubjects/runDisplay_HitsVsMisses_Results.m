function runDisplay_HitsVsMisses_Results

displayResults_HitsVsMisses_StaticResults('SRC-Long',0,1:26,'PreTarget',1,'Misses','both','jet')

displayResults_HitsVsMisses_ConsolidatedResults('SRC-Long',0,1:26,'PreTarget',1,'Misses','both','jet','alpha')
displayResults_HitsVsMisses_ConsolidatedResults('SRC-Long',0,1:26,'PreTarget',1,'Misses','both','jet','gamma')
displayResults_HitsVsMisses_ConsolidatedResults('SRC-Long',0,1:26,'PreTarget',1,'Misses','both','jet','SSVEP')
displayResults_HitsVsMisses_ConsolidatedResults('SRC-Long',1,1:26,'PreTarget',1,'Misses','both','jet','SSVEP')

end