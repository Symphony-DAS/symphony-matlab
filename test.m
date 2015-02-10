import symphonyui.*;

controller = app.Controller();
rigPresenter = presenters.SelectRigPresenter(controller);
result = rigPresenter.view.showDialog();
if result    
    mainPresenter = presenters.MainPresenter(controller);
    mainPresenter.view.show();
end