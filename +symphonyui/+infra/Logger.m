classdef Logger < handle 
    
    properties (Access = private)
        className
    end
    
    methods
        
        function obj = Logger(className)
            obj.className = className;
        end
        
        function debug(obj, message, exception)
            if nargin < 3
                exception = [];
            end
            obj.log('DEBUG', message, exception);
        end
        
        function error(obj, message, exception)
            if nargin < 3
                exception = [];
            end
            obj.log('ERROR', message, exception);
        end
        
        function fatal(obj, message, exception)
            if nargin < 3
                exception = [];
            end
            obj.log('FATAL', message, exception);
        end
        
        function info(obj, message, exception)
            if nargin < 3
                exception = [];
            end
            obj.log('INFO', message, exception);
        end
        
        function warn(obj, message, exception)
            if nargin < 3
                exception = [];
            end
            obj.log('WARN', message, exception);
        end
        
    end
    
    methods (Access = private)
        
        function log(obj, level, message, exception)
            out = sprintf('%s: %s', level, message);
            if ~isempty(exception)
                out = sprintf('%s\n%s', out, exception.getReport());
            end
            
            state = warning();
            warning('off', 'backtrace');
            % FIXME: Matlab won't allow this:
            % warning(obj.id, out);
            warning(out);
            warning(state);
        end
        
        function i = id(obj)
            i = strrep(obj.className, '.', ':');
        end
    
    end
    
end

