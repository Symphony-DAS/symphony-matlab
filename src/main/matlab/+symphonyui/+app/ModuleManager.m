classdef ModuleManager < handle
    
    properties (Access = private)
        log
        documentationService
        acquisitionService
        configurationService
    end
    
    properties (Access = private, Transient)
        modules
    end
    
    methods
        
        function obj = ModuleManager(documentationService, acquisitionService, configurationService)
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
        end
        
        function delete(obj)
            obj.stopModules();
        end
        
        function m = showModule(obj, className)
            for i = 1:numel(obj.modules)
                module = obj.modules{i};
                if strcmp(class(module), className)
                    module.show();
                    m = module;
                    return;
                end
            end
            
            constructor = str2func(className);
            module = constructor();
            module.setDocumentationService(obj.documentationService);
            module.setAcquisitionService(obj.acquisitionService);
            module.setConfigurationService(obj.configurationService);
            module.go();
            obj.modules{end + 1} = module;
            addlistener(module, 'Stopped', @obj.onModuleStopped);
            m = module;
        end
        
        function stopModules(obj)
            while ~isempty(obj.modules)
                obj.modules{1}.stop();
            end
        end
        
    end
    
    methods (Access = private)
        
        function onModuleStopped(obj, module, ~)
            index = cellfun(@(m)m == module, obj.modules);
            obj.modules(index) = [];
        end
        
    end
    
end

