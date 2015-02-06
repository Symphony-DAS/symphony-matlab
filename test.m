import symphonyui.*;

appData = AppData();

setRig = presenters.SetRigPresenter(appData);
result = setRig.view.showDialog();
if result
    main = presenters.MainPresenter(appData);
    main.view.show();
end