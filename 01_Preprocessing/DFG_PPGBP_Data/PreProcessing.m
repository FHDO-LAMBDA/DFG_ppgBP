%% TODO

% DO ONLY PPGI first --> easier
% create epochs or treat 591 beats as continuous? --> maybe easier


% change to this dataset (modeled after Preprocessing for PPG_BP)
% signal parameters --> ppg 2000 hz
% cam resolution? --> necessary?
% ppgSignal ist von camera?
% muss ich mit den Daten noch was machen? Filtern?
% ppg muss noch in abschnitte unterteilt werden --> habe nur kompletten
% strahl
% markers welche Einheit? s! 2.942009000000000e+03 s = ca. 49 min
% cam sync?
% woraus besteht mean beat template? also welcher zeitraum? also wann und
% wie lang?
% zeitstrahl erstellen? --> marker auf ppg legen


% tPPG = 0:(1/referencePPG_samplingRate):(length(referencePPG)-1)/referencePPG_samplingRate;
% plot(tPPG,referencePPG)
% hold on
% xline(markers)
% xline(assessedTimes,'red')

% wie pasen kameraaufnahmen auf zeitstrahl? --> kamera samplerate 100 Hz?
% könnte etwa passen, aber wo start und ende?
% wie passentemplates auf zeitstrahl? 591 10s intervalle? --> das wäre etwa
% doppelt so lang wie die aufnahme...überlappung vllt?
% was sind assessed times?
% --> da +-5s alle beats ensemble? kann ich ja einfach testen


% physmeas table --> NaN jeweils?



clear all
clc

%% setup
% paths
addpath('..\..\NeededFunctions');

if(strcmp(getenv('username'),'vince'))
    networkDrive = 'Y:';
elseif(strcmp(getenv('username'),'Vincent Fleischhauer'))
    networkDrive = 'X:';
elseif(strcmp(getenv('username'),'vifle001'))  
    networkDrive = 'Z:';
else
    errordlg('username not known')
end
baseFolder = [networkDrive,'\FleischhauerVincent\sciebo_appendix\Forschung\Konferenzen\Paper_DFG\Data\Datasets\DFG_PPGBP_Data\'];
sourceFolder=[baseFolder,'measurements\'];
resultsFolder = [baseFolder,'realData\FULL\'];
if(exist(resultsFolder,'dir')~=7)
    mkdir(resultsFolder);
end

%% Parameters
% specify signal parameters
samplingFrequency = 2000; % 2000 Hz sampling frequency
samplingFrequencyPPGI = 100; % 100 Hz sampling frequency ppgi

%% initalize data table
% get patients list
dinfo = dir(sourceFolder);
dinfo(ismember( {dinfo.name}, {'.', '..'})) = [];  %remove . and ..;
patients = {dinfo.name}';
for actualPatientNumber=1:size(patients,1)
    patients{actualPatientNumber} = erase(patients{actualPatientNumber},'.mat');
end

% create table
physiologicalMeasuresTable = table;%create a table where all results are stored
physiologicalMeasuresTable.SubjectID=patients;%create the column for the actual patient ID
physiologicalMeasuresTable.Sex_M_F_=NaN(numel(patients),1);
physiologicalMeasuresTable.Age_year_=NaN(numel(patients),1);
physiologicalMeasuresTable.Height_cm_=NaN(numel(patients),1);
physiologicalMeasuresTable.Weight_kg_=NaN(numel(patients),1);



%% Conversion of data
% orient at CPT
SBPcell = cell(numel(patients),1);
DBPcell = cell(numel(patients),1);
PPcell = cell(numel(patients),1);
HRcell = cell(numel(patients),1);
for actualPatientNumber=1:size(patients,1) % loop over whole dataset
    disp(['patient number: ',num2str(actualPatientNumber)]) % show current patient number in console
    currentPatient = patients{actualPatientNumber};

    % load data
    load([sourceFolder,currentPatient,'.mat'],'meanBeatTemplate','SBP','DBP',...
        'beatStartIndex','beatStopIndex','HR');

    % get number of beats
    numBeats = size(meanBeatTemplate,1);

    % bring data to correct format
    PPGI.values = meanBeatTemplate;
    PPGI.samplerate = samplingFrequencyPPGI;
    PPGI.samplestamp = [0:numel(PPGI.values)-1]'*1000/PPGI.samplerate;%create time axis in milli seconds
    SBPvalues = SBP;
    DBPvalues = DBP;
    HRvalues = HR;

    % save relevant data
    clear('HR','SBP','DBP','meanBeatTemplate')
    save([resultsFolder currentPatient '.mat'],...
        'PPGI', 'beatStartIndex','beatStopIndex');
    clear('PPGI', 'beatStartIndex','beatStopIndex');

    % create BP vectors
    SBP = struct;
    SBP.values = zeros(numBeats,1);
    SBP.values(:) = SBPvalues;
    SBPcell{actualPatientNumber} = SBP;
    DBP = struct;
    DBP.values = zeros(numBeats,1);
    DBP.values(:) = DBPvalues;
    DBPcell{actualPatientNumber} = DBP;
    PP = struct;
    PP.values = SBP.values - DBP.values;
    PPcell{actualPatientNumber} = PP;
    % create HR vector
    HR = struct;
    HR.values = zeros(numBeats,1);
    HR.values(:) = HRvalues;
    HRcell{actualPatientNumber} = HR;
end
SBPtab = cell2table(SBPcell,'VariableNames',{'SBP'});
physiologicalMeasuresTable = [physiologicalMeasuresTable,SBPtab];
DBPtab = cell2table(DBPcell,'VariableNames',{'DBP'});
physiologicalMeasuresTable = [physiologicalMeasuresTable,DBPtab];
PPtab = cell2table(PPcell,'VariableNames',{'PP'});
physiologicalMeasuresTable = [physiologicalMeasuresTable,PPtab];
HRtab = cell2table(HRcell,'VariableNames',{'HR'});
physiologicalMeasuresTable = [physiologicalMeasuresTable,HRtab];

% save physiological measures table
save([resultsFolder 'physiologicalMeasuresTable.mat'],'physiologicalMeasuresTable');