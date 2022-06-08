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

clear index; index=47; deviceNames{index} = 'BP'; subjectNames{index} = 'SSP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=48; deviceNames{index} = 'BP'; subjectNames{index} = 'SSP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=49; deviceNames{index} = 'BP'; subjectNames{index} = 'SSP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=50; deviceNames{index} = 'BP'; subjectNames{index} = 'SSP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

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

clear index; index=67; deviceNames{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=68; deviceNames{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=69; deviceNames{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=70; deviceNames{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=71; deviceNames{index} = 'BP'; subjectNames{index} = 'SW'; expDates{index} = '120122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=72; deviceNames{index} = 'BP'; subjectNames{index} = 'SW'; expDates{index} = '120122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=73; deviceNames{index} = 'BP'; subjectNames{index} = 'SW'; expDates{index} = '120122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=74; deviceNames{index} = 'BP'; subjectNames{index} = 'SW'; expDates{index} = '120122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=75; deviceNames{index} = 'BP'; subjectNames{index} = 'AR'; expDates{index} = '190122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=76; deviceNames{index} = 'BP'; subjectNames{index} = 'AR'; expDates{index} = '190122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=77; deviceNames{index} = 'BP'; subjectNames{index} = 'AR'; expDates{index} = '190122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=78; deviceNames{index} = 'BP'; subjectNames{index} = 'AR'; expDates{index} = '190122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=75; deviceNames{index} = 'BP'; subjectNames{index} = 'SN'; expDates{index} = '210122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=76; deviceNames{index} = 'BP'; subjectNames{index} = 'SN'; expDates{index} = '210122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=77; deviceNames{index} = 'BP'; subjectNames{index} = 'SN'; expDates{index} = '210122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=78; deviceNames{index} = 'BP'; subjectNames{index} = 'SN'; expDates{index} = '210122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=79; deviceNames{index} = 'BP'; subjectNames{index} = 'DP'; expDates{index} = '220122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=80; deviceNames{index} = 'BP'; subjectNames{index} = 'DP'; expDates{index} = '220122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=81; deviceNames{index} = 'BP'; subjectNames{index} = 'DP'; expDates{index} = '220122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI- 6 Blocks; stopped due to poor EyeTracking and Fixation

clear index; index=82; deviceNames{index} = 'BP'; subjectNames{index} = 'AM'; expDates{index} = '230122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Open
clear index; index=83; deviceNames{index} = 'BP'; subjectNames{index} = 'AM'; expDates{index} = '230122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % Eyes Closed
clear index; index=84; deviceNames{index} = 'BP'; subjectNames{index} = 'AM'; expDates{index} = '230122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI
clear index; index=85; deviceNames{index} = 'BP'; subjectNames{index} = 'AM'; expDates{index} = '230122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 4; % SF-ORI No InterStim

clear index; index=86; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=87; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=88; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=89; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=90; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_005'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=91; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_006'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=92; deviceNames{index} = 'BP'; subjectNames{index} = 'SU'; expDates{index} = '260122'; protocolNames{index} = 'GRF_007'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=93; deviceNames{index} = 'BP'; subjectNames{index} = 'ArD'; expDates{index} = '290122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=94; deviceNames{index} = 'BP'; subjectNames{index} = 'ArD'; expDates{index} = '290122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=95; deviceNames{index} = 'BP'; subjectNames{index} = 'ArD'; expDates{index} = '290122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=96; deviceNames{index} = 'BP'; subjectNames{index} = 'ArD'; expDates{index} = '290122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=97; deviceNames{index} = 'BP'; subjectNames{index} = 'ArD'; expDates{index} = '290122'; protocolNames{index} = 'GRF_005'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=98; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=99; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=100; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=101; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=102; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_005'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=103; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_006'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=104; deviceNames{index} = 'BP'; subjectNames{index} = 'UG'; expDates{index} = '300122'; protocolNames{index} = 'GRF_007'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=105; deviceNames{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '310122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=106; deviceNames{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '310122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=107; deviceNames{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '310122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=108; deviceNames{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '310122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=109; deviceNames{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '310122'; protocolNames{index} = 'GRF_005'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=110; deviceNames{index} = 'BP'; subjectNames{index} = 'SNS'; expDates{index} = '060122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=111; deviceNames{index} = 'BP'; subjectNames{index} = 'SNS'; expDates{index} = '060122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=112; deviceNames{index} = 'BP'; subjectNames{index} = 'SNS'; expDates{index} = '060122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=113; deviceNames{index} = 'BP'; subjectNames{index} = 'SNS'; expDates{index} = '060122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=114; deviceNames{index} = 'BP'; subjectNames{index} = 'SG'; expDates{index} = '080222'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=115; deviceNames{index} = 'BP'; subjectNames{index} = 'SG'; expDates{index} = '080222'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=116; deviceNames{index} = 'BP'; subjectNames{index} = 'SG'; expDates{index} = '080222'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=117; deviceNames{index} = 'BP'; subjectNames{index} = 'SG'; expDates{index} = '080222'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=118; deviceNames{index} = 'BP'; subjectNames{index} = 'MK'; expDates{index} = '090222'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=119; deviceNames{index} = 'BP'; subjectNames{index} = 'MK'; expDates{index} = '090222'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=120; deviceNames{index} = 'BP'; subjectNames{index} = 'MK'; expDates{index} = '090222'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=121; deviceNames{index} = 'BP'; subjectNames{index} = 'MK'; expDates{index} = '090222'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=122; deviceNames{index} = 'BP'; subjectNames{index} = 'SR'; expDates{index} = '160222'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=123; deviceNames{index} = 'BP'; subjectNames{index} = 'SR'; expDates{index} = '160222'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=124; deviceNames{index} = 'BP'; subjectNames{index} = 'SR'; expDates{index} = '160222'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=125; deviceNames{index} = 'BP'; subjectNames{index} = 'SR'; expDates{index} = '160222'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=126; deviceNames{index} = 'BP'; subjectNames{index} = 'RG'; expDates{index} = '240222'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=127; deviceNames{index} = 'BP'; subjectNames{index} = 'RG'; expDates{index} = '240222'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=128; deviceNames{index} = 'BP'; subjectNames{index} = 'RG'; expDates{index} = '240222'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=129; deviceNames{index} = 'BP'; subjectNames{index} = 'RG'; expDates{index} = '240222'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=130; deviceNames{index} = 'BP'; subjectNames{index} = 'IJ'; expDates{index} = '260222'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=131; deviceNames{index} = 'BP'; subjectNames{index} = 'IJ'; expDates{index} = '260222'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=132; deviceNames{index} = 'BP'; subjectNames{index} = 'IJ'; expDates{index} = '260222'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=133; deviceNames{index} = 'BP'; subjectNames{index} = 'IJ'; expDates{index} = '260222'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=134; deviceNames{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '270122'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=135; deviceNames{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '270122'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=136; deviceNames{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '270122'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=137; deviceNames{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '270122'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=138; deviceNames{index} = 'BP'; subjectNames{index} = 'SJP'; expDates{index} = '050322'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=139; deviceNames{index} = 'BP'; subjectNames{index} = 'SJP'; expDates{index} = '050322'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=140; deviceNames{index} = 'BP'; subjectNames{index} = 'SJP'; expDates{index} = '050322'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=141; deviceNames{index} = 'BP'; subjectNames{index} = 'SJP'; expDates{index} = '050322'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

clear index; index=142; deviceNames{index} = 'BP'; subjectNames{index} = 'SC'; expDates{index} = '080322'; protocolNames{index} = 'GRF_001'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=143; deviceNames{index} = 'BP'; subjectNames{index} = 'SC'; expDates{index} = '080322'; protocolNames{index} = 'GRF_002'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=144; deviceNames{index} = 'BP'; subjectNames{index} = 'SC'; expDates{index} = '080322'; protocolNames{index} = 'GRF_003'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG
clear index; index=145; deviceNames{index} = 'BP'; subjectNames{index} = 'SC'; expDates{index} = '080322'; protocolNames{index} = 'GRF_004'; capLayouts{index} = 'actiCap64'; stimTypes{index} = 2; % Behavior + EEG

end
