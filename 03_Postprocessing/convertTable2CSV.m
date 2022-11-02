function[] = convertTable2CSV(mixDatasets,datasetString)

% paths
addpath('..\Algorithms');
load('algorithmsBPestimationTEST.mat','algorithms');


% get path to datasets
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

if(mixDatasets)
    % choose directory
    mixMode = {'interSubject';'intraSubject'};
    ppgi = {'withPPGI';'withoutPPGI'};
    % loop over all tables
    dataset = [];
    for currentDataset = 1:size(datasetString,1)
        dataset = [dataset datasetString{currentDataset,1} datasetString{currentDataset,2} '_'];
    end
    dataset(end) = [];
    for currentMode = 1:size(mixMode,1)
        for currentPPGI = 1:size(ppgi,1)
            matlabDir = [baseDatasetDir dataset '\' mixMode{currentMode} '\' ppgi{currentPPGI} '\'];
            if(exist(matlabDir,'dir')==7)
                load([matlabDir 'dataTables.mat'],'trainTable','testTable');
            else
                continue
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % change all underscores to something else
            % b_a --> b/a
            % all else with math mode?
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get table var names (are the same for both tables)
            varNames = testTable.Properties.VariableNames;
            % change specific entries if they are available, change all other
            specialCases = {{'b_a','b/a'}}; % structure: {{'nameOfVarToBeChanged','changedName'},...}
            for currentCase = 1:numel(specialCases)
                idx = find(strcmp(varNames,specialCases{currentCase}{1}));
                if(~isempty(idx))
                    varNames{idx} = specialCases{currentCase}{2};
                end
            end
            % problematic chars to something else by default
            problematicChars = {{'_','\_'}};
            for currentChar = 1:numel(problematicChars)
                indices = find(contains(varNames,problematicChars{currentChar}{1}));
                if(~isempty(indices))
                    for idx = 1:numel(indices)
                        varNames{indices(idx)} = strrep(varNames{indices(idx)},problematicChars{currentChar}{1},problematicChars{currentChar}{2});
                    end
                end
            end
            % feed var names into tables (same for both tables)
            trainTable.Properties.VariableNames = varNames;
            testTable.Properties.VariableNames = varNames;
            % continue conversion
            writetable(trainTable,[matlabDir 'trainTable.csv']);
            writetable(testTable,[matlabDir 'testTable.csv']);
        end
    end
else
    for actualAlgorithm = 1:size(algorithms,1)
        matlabDir = [baseDatasetDir datasetString{1} '\models' datasetString{2} '\' algorithms{actualAlgorithm} '\'];
        if(exist(matlabDir,'dir')==7)
            load([matlabDir 'modelResults.mat'],'trainTable','testTable','wholeTable');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % change all underscores to something else
        % b_a --> b/a
        % all else with math mode?
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % get table var names (are the same for all tables)
        varNames = testTable.Properties.VariableNames;
        % change specific entries if they are available, change all other
        specialCases = {{'b_a','b/a'}}; % structure: {{'nameOfVarToBeChanged','changedName'},...}
        for currentCase = 1:numel(specialCases)
            idx = find(strcmp(varNames,specialCases{currentCase}{1}));
            if(~isempty(idx))
                varNames{idx} = specialCases{currentCase}{2};
            end
        end
        % problematic chars to something else by default
        problematicChars = {{'_','\_'}};
        for currentChar = 1:numel(problematicChars)
            indices = find(contains(varNames,problematicChars{currentChar}{1}));
            if(~isempty(indices))
                for idx = 1:numel(indices)
                    varNames{indices(idx)} = strrep(varNames{indices(idx)},problematicChars{currentChar}{1},problematicChars{currentChar}{2});
                end
            end
        end
        % feed var names into tables (same for both tables)
        trainTable.Properties.VariableNames = varNames;
        testTable.Properties.VariableNames = varNames;
        wholeTable.Properties.VariableNames = varNames;
        % continue conversion
        writetable(trainTable,[matlabDir 'trainTable.csv']);
        writetable(testTable,[matlabDir 'testTable.csv']);
        writetable(wholeTable,[matlabDir 'wholeTable.csv']);
    end
end
end