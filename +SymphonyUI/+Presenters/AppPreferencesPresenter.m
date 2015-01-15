classdef AppPreferencesPresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        appPreferences
    end
    
    methods
        
        function obj = AppPreferencesPresenter(appPreferences, view)
            if nargin < 2
                view = SymphonyUI.Views.AppPreferencesView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.appPreferences = appPreferences;
            
            obj.addListener(view, 'SelectedCard', @obj.onSelectedCard);
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedCard(obj, ~, ~)
            c = obj.view.getCard();
            disp(c);
        end
        
    end
    
end

