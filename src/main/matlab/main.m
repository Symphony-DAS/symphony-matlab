function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;
    
    setupDotNetPath();
    setupJavaPath();
    
    config = Config();
    config.setDefaults(getDefaultOptions());
    
    persistorFactory = PersistorFactory();
    sourceDescriptionRepository = ObjectRepository('symphonyui.core.descriptions.SourceDescription', config.get(Options.GENERAL_SOURCE_DESCRIPTION_SEARCH_PATH));
    epochGroupDescriptionRepository = ObjectRepository('symphonyui.core.descriptions.EpochGroupDescription', config.get(Options.GENERAL_EPOCH_GROUP_DESCRIPTION_SEARCH_PATH));
    protocolRepository = ObjectRepository('symphonyui.core.Protocol', config.get(Options.GENERAL_PROTOCOL_SEARCH_PATH));
    
    sessionData = SessionData();
    protocols = protocolRepository.getAll();
    sessionData.protocol = protocols{1};
    
    documentationService = DocumentationService(sessionData, persistorFactory, sourceDescriptionRepository, epochGroupDescriptionRepository);
    acquisitionService = AcquisitionService(sessionData, protocolRepository);
    configurationService = ConfigurationService();
%     try %#ok<TRYNC>
%         ids = acquisitionService.getAvailableProtocolIds();
%         acquisitionService.selectProtocol(ids{2});
%     end

    app = App(config);

    presenter = symphonyui.ui.presenters.MainPresenter(documentationService, acquisitionService, configurationService, app);
    presenter.go();
end

function setupDotNetPath()
    import symphonyui.app.App;

    asm = {'Symphony.Core.dll', 'Symphony.ExternalDevices.dll'};

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

    d(Options.GENERAL_RIG_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+rigs')};
    d(Options.GENERAL_PROTOCOL_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+protocols')};
    d(Options.GENERAL_SOURCE_DESCRIPTION_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+sources')};
    d(Options.GENERAL_EPOCH_GROUP_DESCRIPTION_SEARCH_PATH) = {App.getResource('examples/+io/+github/+symphony_das/+epochgroups')};
    d(Options.FILE_DEFAULT_NAME) = @()datestr(now, 'yyyy-mm-dd');
    d(Options.FILE_DEFAULT_LOCATION) = @()pwd();
    d(Options.EPOCH_GROUP_LABEL_LIST) = {'Control', 'Drug', 'Wash'};
    d(Options.SOURCE_LABEL_LIST) = {'Animal', 'Tissue', 'Cell'};
    d(Options.KEYWORD_LIST) = {'Keyword1', 'Keyword2'};
end
