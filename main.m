function fig = main()
    import symphonyui.*;

    controller = app.AppController();
    rigPresenter = presenters.SelectRigPresenter(controller);
    rigPresenter.view.showDialog();
    
    mainPresenter = presenters.MainPresenter(controller);
    mainPresenter.view.show();
    
    fig = mainPresenter.view.getFigureHandle();
end