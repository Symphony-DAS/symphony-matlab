function main()
    import symphonyui.app.*;
    import symphonyui.infra.*;
    
    uix.tracking('off');

    busy = appbox.BusyPresenter('Starting...');
    busy.go();
    deleteBusy = onCleanup(@()delete(busy));

    % MATLAB cannot remove .NET assemblies from the path so only update if this is the first run in the session.
    if isempty(which('Symphony.Core.SymphonyFramework'))
        updater = appbox.GitHubUpdater();
        isUpdate = updater.checkForUpdates(App.owner, App.repo, struct('name', App.name, 'version', App.version));
        if isUpdate
            p = appbox.UpdatePresenter(updater);
            p.goWaitStop();
            info = p.result;
            if ~isempty(info)
                matlab.apputil.run(info.id);
                return;
            end
        end
    end

    addDotNetAssemblies({'Symphony.Core.dll'});
    addJavaJars({'UIExtrasComboBox.jar', 'UIExtrasTable.jar', 'UIExtrasTable2.jar', 'UIExtrasTree.jar', 'UIExtrasPropertyGrid.jar'});

    options = symphonyui.app.Options.getDefault();
    presets = symphonyui.app.Presets.getDefault();

    try
        run(options.startupFile());
    catch x
        warning(['Failed to run startup file: ', x.message]);
    end

    Symphony.Core.Logging.ConfigureLogging(options.loggingConfigurationFile(), options.loggingLogDirectory());

    session = Session(options, presets);
    persistorFactory = PersistorFactory();
    classRepository = ClassRepository(options.searchPath, options.searchPathExclude);

    documentationService = DocumentationService(session, persistorFactory, classRepository);
    acquisitionService = AcquisitionService(session, classRepository);
    configurationService = ConfigurationService(session, classRepository);
    moduleService = ModuleService(session, classRepository, documentationService, acquisitionService, configurationService);

    presenter = symphonyui.ui.presenters.MainPresenter(documentationService, acquisitionService, configurationService, moduleService);
    addlistener(presenter, 'Stopped', @(h,d)session.close());
    addlistener(presenter, 'Stopped', @(h,d)run(options.cleanupFile()));

    delete(busy);
    presenter.showInitializeRig();

    protocols = acquisitionService.getAvailableProtocols();
    [~, i] = sort(appbox.class2display(protocols));
    protocols = protocols(i);
    if numel(protocols) > 0
        presenter.selectProtocol(protocols{1});
    end

    presenter.go();
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
        if ~any(strcmpi(javaclasspath, path))
            javaaddpath(path);
        end
    end
end
