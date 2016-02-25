classdef ModuleService < handle
    
    properties (Access = private)
        session
        classRepository
        moduleManager
    end
    
    methods
        
        function obj = ModuleService(session, classRepository, documentationService, acquisitionService, configurationService)
            obj.session = session;
            obj.classRepository = classRepository;
            obj.moduleManager = symphonyui.app.ModuleManager(documentationService, acquisitionService, configurationService);
        end
        
        function delete(obj)
            obj.moduleManager.stopModules();
        end
        
        function cn = getAvailableModules(obj)
            cn = obj.classRepository.get('symphonyui.ui.Module');
        end
        
        function showModule(obj, className)
            if ~any(strcmp(className, obj.getAvailableModules()))
                error([className ' is not an available module']);
            end
            obj.moduleManager.showModule(className);
        end
        
        function stopModules(obj)
            obj.moduleManager.stopModules();
        end
        
    end
    
end

