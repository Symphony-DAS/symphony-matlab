classdef MeanResponseFigure < symphonyui.core.FigureHandler
    
    properties (SetAccess = private)
        sweepColor
        groupBy
    end
    
    properties (Access = private)
        device
        axesHandle
        sweeps
    end
    
    methods
        
        function obj = MeanResponseFigure(device, varargin)
            obj@symphonyui.core.FigureHandler(device.name);
            try
                obj.device = device;
                obj.parseVargin(varargin{:});
                obj.createUi();
            catch x
                delete(obj.figureHandle);
                rethrow(x);
            end
        end
        
        function parseVargin(obj, varargin)
            ip = inputParser();
            ip.addParameter('sweepColor', 'b', @(x)ischar(x) || isvector(x));
            ip.addParameter('groupBy', [], @(x)iscellstr(x));
            ip.parse(varargin{:});

            obj.sweepColor = ip.Results.sweepColor;
            obj.groupBy = ip.Results.groupBy;
        end
        
        function createUi(obj)
            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle, 'sec');
            obj.sweeps = {};
            
            obj.setTitle([obj.device.name ' Mean Response']);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandle, t);
        end
        
        function clear(obj)
            cla(obj.axesHandle);
            obj.sweeps = {};
        end
        
        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device)
                obj.clear();
                return;
            end
            
            response = epoch.getResponse(obj.device);
            [quantities, units] = response.getData();
            if numel(quantities) > 0
                x = (1:numel(quantities)) / response.sampleRate.quantityInBaseUnits;
                y = quantities;
            else
                x = [];
                y = [];
            end
            
            p = epoch.parameters;
            if isempty(obj.groupBy) && isnumeric(obj.groupBy)
                parameters = p;
            else
                parameters = containers.Map();
                for i = 1:length(obj.groupBy)
                    key = obj.groupBy{i};
                    parameters(key) = p(key);
                end
            end
            
            if isempty(parameters)
                t = 'All epochs grouped together';
            else
                t = ['Grouped by ' strjoin(parameters.keys, ', ')];
            end
            obj.setTitle([obj.device.name ' Mean Response (' t ')']);
            
            sweepIndex = [];
            for i = 1:numel(obj.sweeps)
                if isequal(obj.sweeps{i}.parameters, parameters)
                    sweepIndex = i;
                    break;
                end
            end
            
            if isempty(sweepIndex)
                sweep.line = line(x, y, 'Parent', obj.axesHandle);
                sweep.parameters = parameters;
                sweep.count = 1;
                obj.sweeps{end + 1} = sweep;
            else
                sweep = obj.sweeps{sweepIndex};
                cy = get(sweep.line, 'YData');
                set(sweep.line, 'YData', (cy * sweep.count + y) / (sweep.count + 1));
                sweep.count = sweep.count + 1;
                obj.sweeps{sweepIndex} = sweep;
            end
            
            ylabel(obj.axesHandle, units, 'Interpreter', 'none');
        end
        
        function tf = isequal(obj, other)
            if isempty(obj) || isempty(other) || ~isa(other, class(obj))
                tf = false;
                return;
            end
            tf = obj.device == other.device;
        end
        
    end
        
end

