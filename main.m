function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;

    setupJavaPath();
    
    config = Config();
    config.setDefaults(getDefaults());
    
    experimentFactory = ExperimentFactory();
    rigFactory = RigFactory();
    protocolRepository = ClassRepository('symphonyui.core.Protocol', config.get(Settings.GENERAL_PROTOCOL_SEARCH_PATH));
    
    acquisitionService = AcquisitionService(experimentFactory, rigFactory, protocolRepository);
    
    app = App(config);
    
    presenter = symphonyui.ui.presenters.MainPresenter(acquisitionService, app);
    presenter.showRigConfigurationLoader();
    presenter.go();
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