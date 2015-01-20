import SymphonyUI.*;

pref = Preferences.AppPreferences();
pref.setToDefaults();

ep = pref.epochGroupPreferences;
ep.availableInternalSolutionList = {};
ep.availableOtherList = {'Apple', 'Banana', 'Grape'};

p = Presenters.MainPresenter(pref);
p.view.show();