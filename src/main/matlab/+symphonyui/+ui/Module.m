classdef Module < symphonyui.ui.Presenter
    
    properties (SetAccess = private)
        documentationService
        acquisitionService
        configurationService
    end
    
    methods
        
        function obj = Module()
            view = symphonyui.ui.views.FigureView();
            obj = obj@symphonyui.ui.Presenter([], view);
            
            try
                obj.createUi(view.getFigureHandle());
            catch x
                delete(view);
                rethrow(x);
            end
        end
        
        function setDocumentationService(obj, service)
            obj.documentationService = service;
        end
        
        function setAcquisitionService(obj, service)
            obj.acquisitionService = service;
        end
        
        function setConfigurationService(obj, service)
            obj.configurationService = service;
        end
        
        function delete(obj)
            disp('deleting!');
        end
        
    end
    
    methods (Abstract)
        createUi(obj, figureHandle);
    end
    
end

