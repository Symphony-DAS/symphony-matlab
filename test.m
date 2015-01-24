import symphonyui.*;

pref = preferences.MainPreferences();
pref.setToDefaults();

p = presenters.MainPresenter(pref);
p.view.show();