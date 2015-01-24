classdef View < handle
    
    properties
        position
        result
    end
    
    properties (Access = private)
        parent
        parentListener
    end
    
    properties (Access = protected)
        figureHandle
    end
    
    events
        Closing
    end
    
    methods
        
        function obj = View(parent)            
            if nargin < 1
                parent = [];
            end
            obj.parent = parent;
            if ~isempty(parent)
                obj.parentListener = addlistener(parent, 'Closing', @(h,d)obj.close);
            end
            
            obj.figureHandle = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'HandleVisibility', 'off', ...
                'Visible', 'off', ...
                'DockControls', 'off', ...
                'CloseRequestFcn', @(h,d)obj.close());
            
            if ispc
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Segoe UI');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 9);
            elseif ismac
                set(obj.figureHandle, 'DefaultUicontrolFontName', 'Helvetica Neue');
                set(obj.figureHandle, 'DefaultUicontrolFontSize', 12);
            end
            
            obj.createUI();
        end
        
        function show(obj)
            figure(obj.figureHandle);
        end
        
        function result = showDialog(obj)
            set(obj.figureHandle, 'WindowStyle', 'modal');
            figure(obj.figureHandle);
            uiwait(obj.figureHandle);
            result = obj.result;
        end
        
        function set.result(obj, r)
            obj.result = r;
            obj.close();
        end
        
        function close(obj)
            notify(obj, 'Closing');
            delete(obj.parentListener);
            delete(obj.figureHandle);
        end
        
        function tf = isClosed(obj)
            tf = ~isvalid(obj.figureHandle);
        end
        
        function p = get.position(obj)
            p = get(obj.figureHandle, 'Position');
        end
        
        function set.position(obj, p)
            set(obj.figureHandle, 'Position', p); %#ok<MCSUP>
        end
        
        function savePosition(obj)
            pref = [strrep(class(obj), '.', '_') '_Position'];
            setpref('symphonyui', pref, obj.position);
        end
        
        function loadPosition(obj)
            pref = [strrep(class(obj), '.', '_') '_Position'];
            if ispref('symphonyui', pref)
                obj.position = getpref('symphonyui', pref);
            end
        end
        
        function setWindowKeyPressFcn(obj, fcn)
            set(obj.figureHandle, 'WindowKeyPressFcn', fcn);
        end
        
        function clearUI(obj)
            clf(obj.figureHandle);
        end
        
    end
    
    methods (Abstract)
        createUI(obj);
    end
    
end

