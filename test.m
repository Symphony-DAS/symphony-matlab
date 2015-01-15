import SymphonyUI.*;

pref = Preferences.AppPreferences();
pref.setToDefaults();

ep = pref.epochGroupPreferences;
ep.availableInternalSolutions = {};
ep.availableOthers = {'Apple', 'Banana', 'Grape'};

p = Presenters.MainPresenter(pref);
p.view.show();