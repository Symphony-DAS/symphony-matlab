classdef ExperimentView < symphonyui.ui.View
    
    events
        SelectedNode
    end
    
    properties
        
    end
    
    methods
        
        function obj = ExperimentView(parent)
            obj = obj@symphonyui.ui.View(parent);
        end
        
        function createUI(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Experiment');
            set(obj.figureHandle, 'Position', screenCenter(467, 356));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
        end
        
        function n = getNode(obj)
            n = [];
        end
        
        function setCard(obj, c)
            
        end
        
    end
    
end

