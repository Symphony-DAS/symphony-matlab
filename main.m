function fig = main()
    jpath = { ...
        fullfile(symphonyui.app.App.rootPath, 'bundled', 'PropertyGrid'), ...
        fullfile(symphonyui.app.App.rootPath, 'bundled', 'JavaTreeWrapper', '+uiextras', '+jTree', 'UIExtrasTree.jar')};
    if ~any(ismember(javaclasspath, jpath))
        javaaddpath(jpath);
    end

    app = symphonyui.app.App();

    rigRepository = symphonyui.infra.RigRepository(app.config);
    protocolRepository = symphonyui.infra.ProtocolRepository(app.config);
    
    mainService = symphonyui.app.MainService(rigRepository, protocolRepository);
    
    rigPresenter = symphonyui.ui.presenters.SelectRigPresenter(mainService, app);
    rigPresenter.view.showDialog();
    
    mainPresenter = symphonyui.ui.presenters.MainPresenter(mainService, app);
    mainPresenter.view.show();
    
    fig = mainPresenter.view.getFigureHandle();
end