classdef Module < appbox.Presenter
    
    properties (SetAccess = private)
        documentationService
        acquisitionService
        configurationService
    end
    
    methods
        
        function obj = Module()
            view = symphonyui.ui.views.FigureView();
            obj = obj@appbox.Presenter(view);
            
            try
                obj.createUi(view.getFigureHandle());
            catch x
                delete(view);
                rethrow(x);
            end
        end
        
        function createUi(obj, figureHandle) %#ok<INUSD>
            
        end
        
        function setDocumentationService(obj, service)
            obj.documentationService = service;
            obj.didSetDocumentationService();
        end
        
        function didSetDocumentationService(obj) %#ok<MANU>
            
        end
        
        function setAcquisitionService(obj, service)
            obj.acquisitionService = service;
            obj.didSetAcquisitionService();
        end
        
        function didSetAcquisitionService(obj) %#ok<MANU>
            
        end
        
        function setConfigurationService(obj, service)
            obj.configurationService = service;
            obj.didSetConfigurationService();
        end
        
        function didSetConfigurationService(obj) %#ok<MANU>
            
        end
        
    end
    
end

