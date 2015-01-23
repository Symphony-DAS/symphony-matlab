import SymphonyUI.*;

pref = Preferences.MainPreferences();
pref.setToDefaults();

p = Presenters.MainPresenter(pref);
p.view.show();