classdef AppPreferencesView < SymphonyUI.View
    
    events
        SelectedCard
    end
    
    properties
        cardList
    end
    
    methods
        
        function obj = AppPreferencesView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            
            set(obj.figureHandle, 'Name', 'Preferences');
            set(obj.figureHandle, 'Position', screenCenter(350, 250));
            
            mainLayout = uiextras.HBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.cardList = uicontrol( ...
                'Parent', mainLayout, ...
                'Style', 'list', ...
                'String', {'Experiment', 'Epoch Group', 'Acquisition'}, ...
                'Callback', @(h,d)notify(obj, 'SelectedCard'));
            
            uix.CardPanel( ...
                'Parent', mainLayout);
            
            set(mainLayout, 'Sizes', [-1 -2]);
        end
        
        function c = getCard(obj)
            c = SymphonyUI.Utilities.getSelectedUIValue(obj.cardList);
        end
        
    end
    
end

