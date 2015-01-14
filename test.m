import SymphonyUI.*;

pref = Preferences.AppPreference();
pref.setToDefaults();

ep = pref.epochGroupPreference;
ep.availableInternalSolutions = {'Inter1', 'Inter2', 'Inter3'};
ep.availableOthers = {'Apple', 'Banana', 'Grape'};

p = Presenters.MainPresenter(pref);
p.view.show();