classdef SplitEpochGroupPresenter < appbox.Presenter
    
    properties (Access = private)
        documentationService
        initialGroup
    end
    
    methods
        
        function obj = SplitEpochGroupPresenter(documentationService, initialGroup, view)
            if nargin < 2
                initialGroup = [];
            end
            if nargin < 3
                view = symphonyui.ui.views.SplitEpochGroupView();
            end            
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.documentationService = documentationService;
            obj.initialGroup = initialGroup;
        end
        
    end
    
end

