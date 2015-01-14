import SymphonyUI.*;

pref = Preferences.AppPreference();
pref.setToDefaults();

ep = pref.epochGroupPreference;
ep.availableInternalSolutions = {};
ep.availableOthers = {'Apple', 'Banana', 'Grape'};

p = Presenters.MainPresenter(pref);
p.view.show();