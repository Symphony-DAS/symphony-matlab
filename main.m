function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;

    setupJavaPath();
    
    config = Config();
    config.setDefaults(getDefaultOptions());
    
    experimentFactory = ExperimentFactory();
    rigFactory = RigFactory();
    protocolRepository = ClassRepository('symphonyui.core.Protocol', config.get(Options.GENERAL_PROTOCOL_SEARCH_PATH));
    
    acquisitionService = AcquisitionService(experimentFactory, rigFactory, protocolRepository);
    try %#ok<TRYNC>
        ids = acquisitionService.getAvailableProtocolIds();
        acquisitionService.selectProtocol(ids{2});
    end
    
    app = App(config);
    
    presenter = symphonyui.ui.presenters.MainPresenter(acquisitionService, app);
    presenter.go();
end

function setupJavaPath()
    import symphonyui.app.App;
    
    jpath = { ...
        fullfile(App.getRootPath(), 'dependencies', 'JavaTreeWrapper_20150126', 'JavaTreeWrapper', '+uiextras', '+jTree', 'UIExtrasTree.jar'), ...
        fullfile(App.getRootPath(), 'dependencies', 'PropertyGrid', '+uiextras', '+jide', 'UIExtrasPropertyGrid.jar'), ...
        fullfile(App.getRootPath(), 'dependencies', 'swingx', 'swingx-all-1.6.4.jar')};
    
    if ~any(ismember(javaclasspath, jpath))
        javaaddpath(jpath);
    end
end

function d = getDefaultOptions()
    import symphonyui.app.Options;
    import symphonyui.app.App;
    
    d = containers.Map();
    
    d(Options.GENERAL_RIG_SEARCH_PATH) = {fullfile(App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+rigs')};
    d(Options.GENERAL_PROTOCOL_SEARCH_PATH) = {fullfile(App.getRootPath(), 'examples', '+io', '+github', '+symphony_das', '+protocols')};
    d(Options.EXPERIMENT_DEFAULT_NAME) = @()datestr(now, 'yyyy-mm-dd');
    d(Options.EXPERIMENT_DEFAULT_LOCATION) = @()pwd();
    d(Options.EPOCH_GROUP_LABEL_LIST) = {'Control', 'Drug', 'Wash'};
    d(Options.SOURCE_LABEL_LIST) = {'Animal', 'Tissue', 'Cell'};
end