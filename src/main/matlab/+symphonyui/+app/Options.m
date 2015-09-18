classdef Options < symphonyui.infra.Settings
    
    properties
        protocolSearchPath
        fileDescriptionSearchPath
        sourceDescriptionSearchPath
        epochGroupDescriptionSearchPath
        rigDescriptionSearchPath
        moduleSearchPath
        
        log4netConfigurationFile
        log4netLogDirectory
        
        defaultFileName
        defaultFileLocation
        
        keywordList
    end
    
    methods
        
        function p = get.protocolSearchPath(obj)
            p = obj.get('protocolSearchPath', {symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/+protocols')});
        end
        
        function set.protocolSearchPath(obj, p)
            validateattributes(p, {'cell', 'function_handle'}, {'2d'});
            obj.put('protocolSearchPath', p);
        end
        
        function p = get.fileDescriptionSearchPath(obj)
            p = obj.get('fileDescriptionSearchPath', {symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/+files')});
        end
        
        function set.fileDescriptionSearchPath(obj, p)
            validateattributes(p, {'cell', 'function_handle'}, {'2d'});
            obj.put('fileDescriptionSearchPath', p);
        end
        
        function p = get.sourceDescriptionSearchPath(obj)
            p = obj.get('sourceDescriptionSearchPath', {symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/+sources')});
        end
        
        function set.sourceDescriptionSearchPath(obj, p)
            validateattributes(p, {'cell', 'function_handle'}, {'2d'});
            obj.put('sourceDescriptionSearchPath', p);
        end
        
        function p = get.epochGroupDescriptionSearchPath(obj)
            p = obj.get('epochGroupDescriptionSearchPath', {symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/+epochgroups')});
        end
        
        function set.epochGroupDescriptionSearchPath(obj, p)
            validateattributes(p, {'cell', 'function_handle'}, {'2d'});
            obj.put('epochGroupDescriptionSearchPath', p);
        end
        
        function p = get.rigDescriptionSearchPath(obj)
            p = obj.get('rigDescriptionSearchPath', {symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/+rigs')});
        end
        
        function set.rigDescriptionSearchPath(obj, p)
            validateattributes(p, {'cell', 'function_handle'}, {'2d'});
            obj.put('rigDescriptionSearchPath', p);
        end
        
        function p = get.moduleSearchPath(obj)
            p = obj.get('moduleSearchPath', {symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/+modules')});
        end
        
        function set.moduleSearchPath(obj, p)
            validateattributes(p, {'cell', 'function_handle'}, {'2d'});
            obj.put('moduleSearchPath', p);
        end
        
        function f = get.log4netConfigurationFile(obj)
            f = obj.get('log4netConfigurationFile', symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/log.xml'));
        end
        
        function set.log4netConfigurationFile(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'row'});
            obj.put('log4netConfigurationFile', f)
        end
        
        function f = get.log4netLogDirectory(obj)
            f = obj.get('log4netLogDirectory', symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/logs'));
        end
        
        function set.log4netLogDirectory(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'row'});
            obj.put('log4netLogDirectory', f)
        end
        
        function n = get.defaultFileName(obj)
            n = obj.get('defaultFileName', @()datestr(now, 'yyyy-mm-dd'));
        end
        
        function set.defaultFileName(obj, n)
            validateattributes(n, {'char', 'function_handle'}, {'row'});
            obj.put('defaultFileName', n);
        end
        
        function n = get.defaultFileLocation(obj)
            n = obj.get('defaultFileLocation', @()pwd());
        end
        
        function set.defaultFileLocation(obj, n)
            validateattributes(n, {'char', 'function_handle'}, {'row'});
            obj.put('defaultFileLocation', n);
        end
        
    end
    
    methods (Static)
        
        function o = getDefault()
            persistent default;
             if isempty(default) || ~isvalid(default)
                default = symphonyui.app.Options();
             end
             o = default;
        end
        
    end
    
end

