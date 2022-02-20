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
doDecomposition = true;
doFeatureExtraction = false;
doTraining = false;
doTesting = false;

%% get path to datasets
if(strcmp(getenv('username'),'vince'))
    networkDrive = 'Y:';
elseif(strcmp(getenv('username'),'Vincent Fleischhauer'))
    networkDrive = 'X:';
else
    errordlg('username not known')
end
baseDatasetDir = [networkDrive,'\FleischhauerVincent\sciebo_appendix\Forschung\Konferenzen\Paper_PPG_BP\Data\Datasets\'];

%% initialize settings
settings = struct;

%% decomposeRealData
if(doDecomposition)
    settings.Decomposition = struct;
    
    % settings
    settings.Decomposition.doExclusion = false;
    settings.Decomposition.extractFullDataset = true;
    settings.Decomposition.nrmseThreshold = 0.4;
    settings.Decomposition.dataset ='CPT';

    % dirs
    settings.Decomposition.toDir = '2022_02_16'; % ending of dir to which data will be saved

    % execute function that stores settings
    storeSettings(baseDatasetDir,settings);
    settings = rmfield(settings,'Decomposition');

    % execute function
    decomposeRealData(baseDatasetDir,settings.Decomposition.toDir, ...
        settings.Decomposition.doExclusion,settings.Decomposition.extractFullDataset,...
        settings.Decomposition.nrmseThreshold,settings.Decomposition.dataset)
    
end

%% extractFeatures
if(doFeatureExtraction)
    % settings
    settings.Features.extractFullDataset = false;
    settings.Features.usePreviousResults = false;
    settings.Features.dataset ='CPT';
    settings.Features.extractPPGI = false;
    settings.Features.extractPPGIensemble = true;
    % settings.Features.metaDataFeatures = {'ID';'Beat';'Sex';'Age';'Height';'Weight';'SBP';'DBP';'PP';'TPR'}; % add RR
    settings.Features.metaDataFeatures = {'ID';'Beat';'Sex';'Age';'Height';'Weight';'SBP';'DBP';'PP'}; % add RR % add epoch?

    % dirs
    settings.Features.fromDir = '2022_02_17'; % ending of dir from which data should be used as input
    settings.Features.toDir = '2022_02_17'; % ending of dir to which data will be saved

    % execute function that stores settings
    storeSettings(baseDatasetDir,settings);
    settings = rmfield(settings,'Features');

    % execute function
    extractFeatures(baseDatasetDir,settings.Features.fromDir,settings.Features.toDir, ...
        settings.Features.extractFullDataset,settings.Features.usePreviousResults, ...
        settings.Features.dataset,settings.Features.extractPPGI, ...
        settings.Features.extractPPGIensemble,settings.Features.metaDataFeatures)
end

%% trainModels
if(doTraining)
    % settings
    mixDatasets = true;
    intraSubjectMix = true; % Bedeutung: Zufälliges Ziehen aus allen Schlägen
    mixHu = true; % Bedeutung: Zufääligen Ziehen aus allen Schlägen eines Probanden
    includePPGI = true;
    PPGIdir = 'beatwiseFeaturesSUBSET_NOEX_2022_01_20\';
    % modelTypes = {'LinearMixedModel','LinearMixedModel'; ...
    %     'LinearModel','LinearModel';...
    %     'RandomForest','classreg.learning.regr.RegressionEnsemble'};
    modelTypes = {'RandomForest','classreg.learning.regr.RegressionEnsemble'};
    portionTraining = 0.8;
    if(mixDatasets)
        dataset = {'CPT','FULL';'PPG_BP','SUBSET'};
    else
        dataset = {'CPT','FULL'};
        %dataset = {'PPG_BP','SUBSET'};
    end

    % dirs
    fromDir = '2022_02_02'; % ending of dir from which data should be used as input
    toDir = '2022_02_02'; % ending of dir to which data will be saved
    % function that reads input dir for a file that contains information on
    % which data is used for calculation and takes this information and adds
    % new information from this section here

    % execute function
    trainModels(baseDatasetDir,dirEnding,mixDatasets,intraSubjectMix,mixHu,...
        includePPGI,PPGIdir,modelTypes,portionTraining,dataset)
end

%% testModels
if(doTesting)
    % settings
    doDummyError = {false,'SBP'}; % discards trained model for a comparison of test data with mean of trainings data, test data and all data --> each comparison is treated as a 'model'
    doVisualization = {true,'','all',true,{true,'all'}}; % (1) true = plots are created; (2) 'singles' = figures for each subject separately; (3) 'all' = only combined figure; (4) true = background color divides subjects, (5) 'all' or cell containing chars that define features to be plottet with BP
    modelTypes = {'RandomForest'};
    %modelTypes = {'LinearMixedModel';'LinearModel';'RandomForest'};
    mixDatasets = true;
    intraSubjectMix = false;
    includePPGI = false;
    if(mixDatasets)
        set = 'CPTFULL_PPG_BPSUBSET';
    else
        set = {{'CPT';'FULL'},{'PPG_BP';'SUBSET'}};
        %     testSet = {'CPT';'FULL'};
        %     trainingSet = {'PPG_BP';'SUBSET'};
    end

    % dirs
    fromDir = '2022_02_02'; % ending of dir from which data should be used as input
    toDir = '2022_02_02'; % ending of dir to which data will be saved
    % function that reads input dir for a file that contains information on
    % which data is used for calculation and takes this information and adds
    % new information from this section here

    % execute function
    testModels(baseDatasetDir,dirEnding,doDummyError,doVisualization,...
        modelTypes,mixDatasets,intraSubjectMix,includePPGI,set)
end