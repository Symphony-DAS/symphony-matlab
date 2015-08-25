classdef ModuleService < handle
    
    properties (Access = private)
        session
        moduleRepository
        documentationService
        acquisitionService
        configurationService
    end
    
    methods
        
        function obj = ModuleService(session, moduleRepository, documentationService, acquisitionService, configurationService)
            obj.session = session;
            obj.moduleRepository = moduleRepository;
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
        end
        
        function cn = getAvailableModules(obj)
            cn = obj.moduleRepository.getAll();
        end
        
        function showModule(obj, className)
            if ~any(strcmp(className, obj.getAvailableModules()))
                error([className ' is not an available module']);
            end
            constructor = str2func(className);
            module = constructor();
            module.setDocumentationService(obj.documentationService);
            module.setAcquisitionService(obj.acquisitionService);
            module.setConfigurationService(obj.configurationService);
            module.go();
        end
        
    end
    
end

