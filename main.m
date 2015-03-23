function main()
    jpath = { ...
        fullfile(symphonyui.app.App.getRootPath(), 'bundled', 'PropertyGrid'), ...
        fullfile(symphonyui.app.App.getRootPath(), 'bundled', 'JavaTreeWrapper', '+uiextras', '+jTree', 'UIExtrasTree.jar')};
    if ~any(ismember(javaclasspath, jpath))
        javaaddpath(jpath);
    end

    app = symphonyui.app.App();
    
    experimentFactory = symphonyui.infra.ExperimentFactory();
    rigRepository = symphonyui.infra.RigRepository(app.config);
    protocolRepository = symphonyui.infra.ProtocolRepository(app.config);
    
    acquisitionService = symphonyui.app.AcquisitionService(experimentFactory, rigRepository, protocolRepository);
    
    rigPresenter = symphonyui.ui.presenters.SelectRigPresenter(acquisitionService, app);
    rigPresenter.goWaitStop();
    
    mainPresenter = symphonyui.ui.presenters.MainPresenter(acquisitionService, app);
    mainPresenter.go();
end