function [subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts] = allCommonProtocolsHumanEEG
clear index; index=1; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % Eyes Open  
clear index; index=2; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % Eyes Closed
clear index; index=3; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 3;  % GRF protocol- TF tuning
clear index; index=4; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '290121'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % GRF protocol- SF-Ori

clear index; index=5; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % Eyes Open  
clear index; index=6; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % Eyes Closed
clear index; index=7; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % GRF protocol- - SF-Ori- 10 blocks
clear index; index=8; deviceNames{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % GRF protocol- - SF-Ori- 20 blocks

clear index; index=9; deviceNames{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % Eyes Closed
clear index; index=10; deviceNames{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % GRF protocol- - SF-Ori- 10 blocks
clear index; index=11; deviceNames{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2;  % GRF protocol- - SF-Ori- 20 blocks

clear index; index=12; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; 
clear index; index=13; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; 
clear index; index=14; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; 

clear index; index=15; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=16; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=17; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-Ori
clear index; index=18; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_009'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=19; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_010'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=20; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-Ori No InterStim

clear index; index=21; deviceNames{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270821'; protocolNames{index} = 'Ref1_Gnd1'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=22; deviceNames{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270821'; protocolNames{index} = 'Ref2_Gnd1'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=23; deviceNames{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270821'; protocolNames{index} = 'Ref3_Gnd1'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=24; deviceNames{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270821'; protocolNames{index} = 'Ref1_Gnd2'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=25; deviceNames{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270821'; protocolNames{index} = 'Ref2_Gnd2'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=26; deviceNames{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270821'; protocolNames{index} = 'Ref3_Gnd2'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed

clear index; index=27; deviceNames{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=28; deviceNames{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=29; deviceNames{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=30; deviceNames{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_005'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=31; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=32; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=33; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=34; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=35; deviceNames{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=36; deviceNames{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=37; deviceNames{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=38; deviceNames{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=39; deviceNames{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=40; deviceNames{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=41; deviceNames{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=42; deviceNames{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=43; deviceNames{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=44; deviceNames{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=45; deviceNames{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=46; deviceNames{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=47; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=48; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=49; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=50; deviceNames{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=51; deviceNames{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=52; deviceNames{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=53; deviceNames{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=54; deviceNames{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=55; deviceNames{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=56; deviceNames{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=57; deviceNames{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=58; deviceNames{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=59; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=60; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=61; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=62; deviceNames{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_005'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=63; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=64; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=65; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=66; deviceNames{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

end
