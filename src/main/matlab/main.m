function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;
    
    addDotNetAssemblies({'Symphony.Core.dll'});
    addJavaJars({'UIExtrasTree.jar', 'UIExtrasPropertyGrid.jar'});
    
    options = symphonyui.app.Options.getDefault();
    
    Symphony.Core.Logging.ConfigureLogging(options.log4netConfigurationFile, options.log4netLogDirectory);
    
    session = Session();
    persistorFactory = PersistorFactory();
    fileDescriptionRepository = ClassRepository('symphonyui.core.descriptions.FileDescription', options.fileDescriptionSearchPath);
    sourceDescriptionRepository = ClassRepository('symphonyui.core.descriptions.SourceDescription', options.sourceDescriptionSearchPath);
    epochGroupDescriptionRepository = ClassRepository('symphonyui.core.descriptions.EpochGroupDescription', options.epochGroupDescriptionSearchPath);
    protocolRepository = ClassRepository('symphonyui.core.Protocol', options.protocolSearchPath);
    rigDescriptionRepository = ClassRepository('symphonyui.core.descriptions.RigDescription', options.rigDescriptionSearchPath);
    moduleRepository = ClassRepository('symphonyui.ui.Module', options.moduleSearchPath);
    
    documentationService = DocumentationService(session, persistorFactory, fileDescriptionRepository, sourceDescriptionRepository, epochGroupDescriptionRepository);
    acquisitionService = AcquisitionService(session, protocolRepository);
    configurationService = ConfigurationService(session, rigDescriptionRepository);
    moduleService = ModuleService(session, moduleRepository, documentationService, acquisitionService, configurationService);
    
    presenter = symphonyui.ui.presenters.MainPresenter(documentationService, acquisitionService, configurationService, moduleService);
    addlistener(presenter, 'ObjectBeingDestroyed', @(h,d)session.close());
    presenter.go();
    
    protocols = acquisitionService.getAvailableProtocols();
    if numel(protocols) > 0
        presenter.selectProtocol(protocols{1});
    end
    
    presenter.openInitializeRig();
end

function addDotNetAssemblies(asms)
    for i = 1:numel(asms)
        path = which(asms{i});
        if isempty(path)
            error(['Cannot find ' asms{i} ' on the matlab path']);
        end
        NET.addAssembly(path);
    end
end

function addJavaJars(jars)
    for i = 1:numel(jars)
        path = which(jars{i});
        if isempty(path)
            error(['Cannot find ' jars{i} ' on the matlab path']);
        end
        if ~ismember(javaclasspath, path)
            javaaddpath(path);
        end
    end
end
