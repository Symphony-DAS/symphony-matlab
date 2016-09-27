classdef MergeEpochGroupsPresenter < appbox.Presenter
    
    properties (Access = private)
        documentationService
        initialGroup1
    end
    
    methods
        
        function obj = MergeEpochGroupsPresenter(documentationService, initialGroup1, view)
            if nargin < 2
                initialGroup1 = [];
            end
            if nargin < 3
                view = symphonyui.ui.views.MergeEpochGroupsView();
            end            
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.documentationService = documentationService;
            obj.initialGroup1 = initialGroup1;
        end
        
    end
    
end

