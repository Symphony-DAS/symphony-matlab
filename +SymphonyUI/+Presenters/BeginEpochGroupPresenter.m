classdef BeginEpochGroupPresenter < SymphonyUI.Presenter
    
    properties
    end
    
    methods
        
        function viewDidLoad(obj)
            obj.view.centerOnScreen(518, 276);           
        end
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedBegin();
            elseif strcmp(data.Key, 'escape')
                obj.onSelectedClose();
            end
        end
        
        function onSelectedBegin(obj, ~, ~)
            obj.view.epochGroup = SymphonyUI.Models.EpochGroup('');
            obj.view.close();
        end
        
    end
    
end

