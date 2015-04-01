function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;

    setupJavaPath();
    
    config = Config();
    config.setDefaults(getDefaults());
    
    experimentFactory = ExperimentFactory();
    
    rigRepository = DiscoverableRepository('symphonyui.core.Rig');
    rigRepository.setSearchPaths([ ...
        fullfile(App.getRootPath(), '+symphonyui', '+infra', '+nulls'), ...
        config.get(Settings.GENERAL_RIG_SEARCH_PATH)]);
    rigRepository.loadAll();
    
    protocolRepository = DiscoverableRepository('symphonyui.core.Protocol');
    protocolRepository.setSearchPaths([ ...
        fullfile(App.getRootPath(), '+symphonyui', '+infra', '+nulls'), ...    
        config.get(Settings.GENERAL_PROTOCOL_SEARCH_PATH)]);
    protocolRepository.loadAll();
    
    acquisitionService = AcquisitionService(experimentFactory, rigRepository, protocolRepository);
    
    app = App(config);
    
    rigPresenter = symphonyui.ui.presenters.SelectRigPresenter(acquisitionService, app);
    rigPresenter.goWaitStop();
    
    mainPresenter = symphonyui.ui.presenters.MainPresenter(acquisitionService, app);
    mainPresenter.go();
end

function setupJavaPath()
    import symphonyui.app.App;
    
    jpath = { ...
        fullfile(App.getRootPath(), 'dependencies', 'JavaTreeWrapper_20150126', 'JavaTreeWrapper', '+uiextras', '+jTree', 'UIExtrasTree.jar'), ...
        fullfile(App.getRootPath(), 'dependencies', 'PropertyGrid', '+uiextras', '+jide', 'UIExtrasPropertyGrid.jar')};
    
    if ~any(ismember(javaclasspath, jpath))
        javaaddpath(jpath);
    end
end

function d = getDefaults()
    import symphonyui.app.Settings;
    import symphonyui.app.App;
    
    d = containers.Map();
    
    d(Settings.GENERAL_RIG_SEARCH_PATH) = {fullfile(App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+rigs')};
    d(Settings.GENERAL_PROTOCOL_SEARCH_PATH) = {fullfile(App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+protocols')};
    d(Settings.EXPERIMENT_DEFAULT_NAME) = @()datestr(now, 'yyyy-mm-dd');
    d(Settings.EXPERIMENT_DEFAULT_LOCATION) = @()pwd();
    d(Settings.EPOCH_GROUP_LABEL_LIST) = {'Control', 'Drug', 'Wash'};
    d(Settings.SOURCE_LABEL_LIST) = {'Animal', 'Tissue', 'Cell'};
end