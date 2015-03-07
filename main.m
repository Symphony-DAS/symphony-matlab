function fig = main()
    app = symphonyui.app.App();

    rigRepository = symphonyui.app.repos.RigRepository(app.config);
    protocolRepository = symphonyui.app.repos.ProtocolRepository(app.config);
    
    mainService = symphonyui.app.services.MainService(rigRepository, protocolRepository);
    
    rigPresenter = symphonyui.ui.presenters.SelectRigPresenter(mainService, app);
    rigPresenter.view.showDialog();
    
    mainPresenter = symphonyui.ui.presenters.MainPresenter(mainService, app);
    mainPresenter.view.show();
    
    fig = mainPresenter.view.getFigureHandle();
end