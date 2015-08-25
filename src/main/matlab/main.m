function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;
    
    setupDotNetPath();
    setupJavaPath();
    
    config = Config();
    config.setDefaults(getDefaultOptions());
    
    persistorFactory = PersistorFactory();
    fileDescriptionRepository = ClassRepository('symphonyui.core.descriptions.FileDescription', config.get(Options.GENERAL_FILE_DESCRIPTION_SEARCH_PATH));
    sourceDescriptionRepository = ClassRepository('symphonyui.core.descriptions.SourceDescription', config.get(Options.GENERAL_SOURCE_DESCRIPTION_SEARCH_PATH));
    epochGroupDescriptionRepository = ClassRepository('symphonyui.core.descriptions.EpochGroupDescription', config.get(Options.GENERAL_EPOCH_GROUP_DESCRIPTION_SEARCH_PATH));
    
    protocolRepository = ClassRepository('symphonyui.core.Protocol', config.get(Options.GENERAL_PROTOCOL_SEARCH_PATH));
    
    rigDescriptionRepository = ClassRepository('symphonyui.core.descriptions.RigDescription', config.get(Options.GENERAL_RIG_DESCRIPTION_SEARCH_PATH));
    
    moduleRepository = ClassRepository('symphonyui.ui.Module', config.get(Options.GENERAL_MODULE_SEARCH_PATH));
    
    session = Session();
    
    documentationService = DocumentationService(session, persistorFactory, fileDescriptionRepository, sourceDescriptionRepository, epochGroupDescriptionRepository);
    acquisitionService = AcquisitionService(session, protocolRepository);
    configurationService = ConfigurationService(session, rigDescriptionRepository);
    moduleService = ModuleService(session, moduleRepository, documentationService, acquisitionService, configurationService);
    
    cn = acquisitionService.getAvailableProtocols();
    acquisitionService.selectProtocol(cn{1});

    app = App(config);
    
    presenter = symphonyui.ui.presenters.MainPresenter(documentationService, acquisitionService, configurationService, moduleService, app);
    addlistener(presenter, 'ObjectBeingDestroyed', @(h,d)session.close());
    presenter.go();
end

function setupDotNetPath()
    import symphonyui.app.App;

    asm = {'Symphony.Core.dll'};

    for i = 1:numel(asm)
        path = which(asm{i});
        if isempty(path)
            error(['Cannot find ' asm{i} ' on the matlab path']);
        end
        NET.addAssembly(path);
    end
end

function setupJavaPath()
    import symphonyui.app.App;

    jar = {'UIExtrasTree.jar', 'UIExtrasPropertyGrid.jar'};

    for i = 1:numel(jar)
        path = which(jar{i});
        if isempty(path)
            error(['Cannot find ' jar{i} ' on the matlab path']);
        end
        if ~ismember(javaclasspath, path)
            javaaddpath(path);
        end
    end
end

function d = getDefaultOptions()
    import symphonyui.app.Options;
    import symphonyui.app.App;

    d = containers.Map();
    
    d(Options.GENERAL_PROTOCOL_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+protocols')};
    d(Options.GENERAL_FILE_DESCRIPTION_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+files')};
    d(Options.GENERAL_SOURCE_DESCRIPTION_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+sources')};
    d(Options.GENERAL_EPOCH_GROUP_DESCRIPTION_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+epochgroups')};
    d(Options.GENERAL_RIG_DESCRIPTION_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+rigs')};
    d(Options.GENERAL_MODULE_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+modules')};
    d(Options.FILE_DEFAULT_NAME) = @()datestr(now, 'yyyy-mm-dd');
    d(Options.FILE_DEFAULT_LOCATION) = @()pwd();
    d(Options.EPOCH_GROUP_LABEL_LIST) = {'Control', 'Drug', 'Wash'};
    d(Options.SOURCE_LABEL_LIST) = {'Animal', 'Tissue', 'Cell'};
    d(Options.KEYWORD_LIST) = {'Keyword1', 'Keyword2'};
end
