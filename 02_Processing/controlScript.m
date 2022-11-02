clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% in den Funktionen noch die Pfade an die Übergebenen Pfade anpassen
% --> dafür aber erst Zusammenführung sinnvoll machen

% einbauen, dass auf alte Ergebnisse zugegriffen wird, wenn bestimmte TEile
% nicht ausgeführt werden

% what about "load algorithms" Befehle?

% finales Abspeichern der Daten anders machen --> sodass nicht einfach
% überschrieben wird --> check durchführen, ob da was existiert und wenn
% nicht "überschreiben" angewählt ist, Order

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% choose steps to be executed
doDecomposition = false;
doFeatureExtraction = false;
doTraining = true;
doTesting = true;

%% get path to datasets
if(strcmp(getenv('username'),'vince'))
    networkDrive = 'Y:';
elseif(strcmp(getenv('username'),'Vincent Fleischhauer'))
    networkDrive = 'X:';
elseif(strcmp(getenv('username'),'vifle001'))  
    networkDrive = 'Z:';
else
    errordlg('username not known')
end
baseDatasetDir = [networkDrive,'\FleischhauerVincent\sciebo_appendix\Forschung\Konferenzen\Paper_DFG\Data\Datasets\'];

%% initialize settings
settings = struct;

%% decomposeRealData
if(doDecomposition)
    settings.Decomposition = struct;
    
    % settings
    settings.Decomposition.doExclusion = false;
    settings.Decomposition.extractFullDataset = true;
    settings.Decomposition.nrmseThreshold = 0.4;
    settings.Decomposition.dataset ='DFG_PPGBP_Data';
    settings.Decomposition.algorithmsFile = 'algorithmsBPestimationTEST';
    % settings only for subset
    settings.Decomposition.extractPPGIsingles = false;
    settings.Decomposition.extractPPGIensemble = false;

    % dirs
    settings.Decomposition.toDir = '2022_10_05'; % ending of dir to which data will be saved

    % execute function that stores settings
    storeSettings(baseDatasetDir,settings);

    % execute function
    decomposeRealData(baseDatasetDir,settings.Decomposition.toDir,settings.Decomposition.doExclusion, ...
        settings.Decomposition.algorithmsFile,settings.Decomposition.extractFullDataset,...
        settings.Decomposition.nrmseThreshold,settings.Decomposition.dataset, ...
        settings.Decomposition.extractPPGIsingles,settings.Decomposition.extractPPGIensemble)

    % remove current settings
    settings = rmfield(settings,'Decomposition');
    
end

%% extractFeatures
% for subset this function can only handle one data class at a time (i.e.
% you need 2 calls of this function to 
if(doFeatureExtraction)
    % settings
    settings.Features.extractFullDataset = true;
    settings.Features.usePreviousResults = false;
    settings.Features.dataset ='DFG_PPGBP_Data';
    % settings.Features.metaDataFeatures = {'ID';'Beat';'Sex';'Age';'Height';'Weight';'SBP';'DBP';'PP';'TPR'}; % add RR
    settings.Features.metaDataFeatures = {'ID';'Beat';'Sex';'Age';'Height';'Weight';'SBP';'DBP';'PP';'HR'}; % add RR % add epoch?
    % settings only for subset
    settings.Features.dataClass ='ppg'; % ppg, ppgiSingles, ppgiEnsemble

    % dirs
    settings.Features.fromDir = '2022_10_05'; % ending of dir from which data should be used as input
    settings.Features.toDir = '2022_10_05'; % ending of dir to which data will be saved

    % execute function that stores settings
    storeSettings(baseDatasetDir,settings);

    % execute function
    extractFeatures(baseDatasetDir,settings.Features.fromDir,settings.Features.toDir, ...
        settings.Features.extractFullDataset,settings.Features.usePreviousResults, ...
        settings.Features.dataset,settings.Features.dataClass, ...
        settings.Features.metaDataFeatures)

    % remove current settings
    settings = rmfield(settings,'Features');
end

%% trainModels
if(doTraining)
    randomState = rng; % save state of random number generator
    numRuns = 1;
    for currentRun = 1:numRuns
    % settings
    mixDatasets = false;
    intraSubjectMix = [false,true]; % Bedeutung: Zufälliges Ziehen aus allen Schlägen
    mixHu = true; % Bedeutung: Zufääligen Ziehen aus allen Schlägen eines Probanden
    includePPGI = [false,false];
    PPGIdir = 'Features\SUBSET\2022_04_05\';
    modelTypes = {'RandomForest','classreg.learning.regr.RegressionEnsemble'};
    portionTraining = 0.8;
    if(mixDatasets)
        dataset = {'CPT','FULL';'Queensland','FULL'};
        dataset = {'CPT','FULL';'Queensland','FULL';'PPG_BP','SUBSET'};
    else
        dataset = {'DFG_PPGBP_Data','FULL'};
    end

    % dirs
    fromDir = '2022_10_05'; % ending of dir from which data should be used as input
    toDir = '2022_10_05'; % ending of dir to which data will be saved

    % execute function
    trainModels(baseDatasetDir,fromDir,toDir,mixDatasets,intraSubjectMix(currentRun), ...
        mixHu,includePPGI(currentRun),PPGIdir,modelTypes,portionTraining,dataset,randomState)
    end
    
    % convert data tables
    addpath('..\03_Postprocessing');
    convertTable2CSV(mixDatasets,dataset);
    
end

%% testModels
if(doTesting)
    numRuns = 1;
    for currentRun = 1:numRuns
    % settings
    doDummyError = {false,'SBP'}; % discards trained model for a comparison of test data with mean of trainings data, test data and all data --> each comparison is treated as a 'model'
    doVisualization = {false,'','all',true,{true,'all'}}; % (1) true = plots are created; (2) 'singles' = figures for each subject separately; (3) 'all' = only combined figure; (4) true = background color divides subjects, (5) 'all' or cell containing chars that define features to be plottet with BP
    modelTypes = {'RandomForest'};
    mixDatasets = false;
    intraSubjectMix = [true,false];
    includePPGI = [false,false];
    if(mixDatasets)
        set = 'CPTFULL_QueenslandFULL_PPG_BPSUBSET';
    else
        set = {{'DFG_PPGBP_Data';'FULL'},{'DFG_PPGBP_Data';'FULL'}};
    end

    % dirs
    fromDir = '2022_10_05'; % ending of dir from which data should be used as input
    toDir = '2022_10_05'; % ending of dir to which data will be saved

    % execute function
    testModels(baseDatasetDir,fromDir,toDir,doDummyError,doVisualization,...
        modelTypes,mixDatasets,intraSubjectMix(currentRun),includePPGI(currentRun),set)
    end
end