classdef Options < symphonyui.infra.Settings
    
    properties
        fileDefaultName
        fileDefaultLocation
        searchPath
        loggingConfigurationFile
        loggingLogDirectory
    end
    
    methods
        
        function n = get.fileDefaultName(obj)
            n = obj.get('fileDefaultName', @()datestr(now, 'yyyy-mm-dd'));
        end
        
        function set.fileDefaultName(obj, n)
            validateattributes(n, {'char', 'function_handle'}, {'row'});
            obj.put('fileDefaultName', n);
        end
        
        function n = get.fileDefaultLocation(obj)
            n = obj.get('fileDefaultLocation', @()pwd());
        end
        
        function set.fileDefaultLocation(obj, n)
            validateattributes(n, {'char', 'function_handle'}, {'row'});
            obj.put('fileDefaultLocation', n);
        end
        
        function set.searchPath(obj, p)
            validateattributes(n, {'char', 'function_handle'}, {'row'});
            obj.put('searchPath', p);
        end
        
        function p = get.searchPath(obj)
            p = obj.get('searchPath', symphonyui.app.App.getResource('examples'));
        end
        
        function f = get.loggingConfigurationFile(obj)
            f = obj.get('loggingConfigurationFile', symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/log.xml'));
        end
        
        function set.loggingConfigurationFile(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'row'});
            obj.put('loggingConfigurationFile', f)
        end
        
        function f = get.loggingLogDirectory(obj)
            f = obj.get('loggingLogDirectory', symphonyui.app.App.getResource('examples/+io/+github/+symphony_das/logs'));
        end
        
        function set.loggingLogDirectory(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'row'});
            obj.put('loggingLogDirectory', f)
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

