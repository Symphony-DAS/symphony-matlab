classdef Options < appbox.Settings

    properties
        startupFile
        cleanupFile
        warnOnViewOnlyWithOpenFile
        fileDefaultName
        fileDefaultLocation
        fileCleanupFunction
        searchPath
        searchPathExclude
        loggingConfigurationFile
        loggingLogDirectory
    end

    methods

        function f = get.startupFile(obj)
            f = obj.get('startupFile', '');
        end

        function set.startupFile(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('startupFile', f);
        end
        
        function f = get.cleanupFile(obj)
            f = obj.get('cleanupFile', '');
        end

        function set.cleanupFile(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('cleanupFile', f);
        end
        
        function tf = get.warnOnViewOnlyWithOpenFile(obj)
            tf = obj.get('warnOnViewOnlyWithOpenFile', true);
        end
        
        function set.warnOnViewOnlyWithOpenFile(obj, tf)
            validateattributes(tf, {'logical', 'double'}, {'scalar'});
            obj.put('warnOnViewOnlyWithOpenFile', tf);
        end

        function n = get.fileDefaultName(obj)
            n = obj.get('fileDefaultName', @()datestr(now, 'yyyy-mm-dd'));
        end

        function set.fileDefaultName(obj, n)
            validateattributes(n, {'char', 'function_handle'}, {'2d'});
            obj.put('fileDefaultName', n);
        end

        function n = get.fileDefaultLocation(obj)
            n = obj.get('fileDefaultLocation', @()pwd());
        end

        function set.fileDefaultLocation(obj, n)
            validateattributes(n, {'char', 'function_handle'}, {'2d'});
            obj.put('fileDefaultLocation', n);
        end
        
        function n = get.fileCleanupFunction(obj)
            n = obj.get('fileCleanupFunction', @(documentationService)[]);
        end

        function set.fileCleanupFunction(obj, n)
            validateattributes(n, {'function_handle'}, {'scalar'});
            obj.put('fileCleanupFunction', n);
        end

        function set.searchPath(obj, p)
            validateattributes(p, {'char', 'function_handle'}, {'2d'});
            obj.put('searchPath', p);
        end

        function p = get.searchPath(obj)
            p = obj.get('searchPath', symphonyui.app.App.getResource('examples'));
        end
        
        function set.searchPathExclude(obj, i)
            validateattributes(i, {'char', 'function_handle'}, {'2d'});
            obj.put('searchPathExclude', i);
        end
        
        function i = get.searchPathExclude(obj)
            i = obj.get('searchPathExclude', '');
        end

        function f = get.loggingConfigurationFile(obj)
            f = obj.get('loggingConfigurationFile', symphonyui.app.App.getResource('examples', '+io', '+github', '+symphony_das', 'log.xml'));
        end

        function set.loggingConfigurationFile(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('loggingConfigurationFile', f);
        end

        function f = get.loggingLogDirectory(obj)
            f = obj.get('loggingLogDirectory', fullfile(char(java.lang.System.getProperty('user.home')), '.symphony', 'logs'));
        end

        function set.loggingLogDirectory(obj, f)
            validateattributes(f, {'char', 'function_handle'}, {'2d'});
            obj.put('loggingLogDirectory', f);
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
