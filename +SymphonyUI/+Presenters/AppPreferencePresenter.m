classdef AppPreferencePresenter < SymphonyUI.Presenter
    
    properties (SetAccess = private)
        appPreference
    end
    
    methods
        
        function obj = AppPreferencePresenter(appPreference, view)
            if nargin < 2
                view = SymphonyUI.Views.AppPreferenceView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.appPreference = appPreference;
            
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

