import symphonyui.*;

pref = preferences.AppPreferences();
pref.setToDefaults();

p = presenters.MainPresenter(pref);
p.view.show();