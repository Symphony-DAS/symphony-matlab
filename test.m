import symphonyui.*;

manager = AppManager();

rigPresenter = presenters.SelectRigPresenter(manager);
result = rigPresenter.view.showDialog();
if result
    try %#ok<TRYNC>
        manager.selectProtocol(2);
    end
    
    mainPresenter = presenters.MainPresenter(manager);
    mainPresenter.view.show();
end