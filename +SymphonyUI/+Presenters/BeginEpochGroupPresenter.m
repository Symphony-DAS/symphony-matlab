classdef BeginEpochGroupPresenter < SymphonyUI.Presenter
    
    properties
    end
    
    methods
        
        function onSelectedBegin(obj, ~, ~)
            obj.view.epochGroup = SymphonyUI.Models.EpochGroup('');
            obj.view.close();
        end
        
    end
    
end

