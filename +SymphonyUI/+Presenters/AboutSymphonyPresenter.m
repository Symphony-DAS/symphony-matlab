classdef AboutSymphonyPresenter < SymphonyUI.Presenter
    
    properties
    end
    
    methods
        
        function obj = AboutSymphonyPresenter(version, view)
            if nargin < 2
                view = SymphonyUI.Views.AboutSymphonyView([]);
            end
            
            obj = obj@SymphonyUI.Presenter(view);
            
            obj.addListener(view, 'Ok', @obj.onOk);
            
            text = { ...
                'Symphony Data Acquisition System', ...
                ['Version ' version], ...
                sprintf('%c 2015 Symphony-DAS', 169)};
            obj.view.setAboutText(text);
        end
        
        function onOk(obj, ~, ~)
            obj.view.close();
        end
        
    end
    
end

