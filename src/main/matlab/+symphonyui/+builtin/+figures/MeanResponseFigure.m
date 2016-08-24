classdef MeanResponseFigure < symphonyui.core.FigureHandler
    % Plots the mean response of a specified device for all epochs run.

    properties (SetAccess = private)
        device
        groupBy
        sweepColor
        storedSweepColor
    end

    properties (Access = private)
        axesHandle
        sweeps
    end

    methods

        function obj = MeanResponseFigure(device, varargin)
            co = get(groot, 'defaultAxesColorOrder');

            ip = inputParser();
            ip.addParameter('groupBy', [], @(x)iscellstr(x));
            ip.addParameter('sweepColor', co(1,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor', 'r', @(x)ischar(x) || isvector(x));
            ip.parse(varargin{:});

            obj.device = device;
            obj.groupBy = ip.Results.groupBy;
            obj.sweepColor = ip.Results.sweepColor;
            obj.storedSweepColor = ip.Results.storedSweepColor;

            obj.createUi();
            
            stored = obj.storedSweeps();
            for i = 1:numel(stored)
                stored{i}.line = line(stored{i}.x, stored{i}.y, 'Parent', obj.axesHandle, 'Color', obj.storedSweepColor);
            end
            obj.storedSweeps(stored);
        end

        function createUi(obj)
            import appbox.*;

            toolbar = findall(obj.figureHandle, 'Type', 'uitoolbar');
            storeSweepsButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Store Sweeps', ...
                'Separator', 'on', ...
                'ClickedCallback', @obj.onSelectedStoreSweeps);
            setIconImage(storeSweepsButton, symphonyui.app.App.getResource('icons', 'sweep_store.png'));
            
            clearSweepsButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Clear Sweeps', ...
                'ClickedCallback', @obj.onSelectedClearSweeps);
            setIconImage(clearSweepsButton, symphonyui.app.App.getResource('icons', 'sweep_clear.png'));

            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
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
                error(['Epoch does not contain a response for ' obj.device.name]);
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
                sweep.parameters = parameters;
                sweep.x = x;
                sweep.y = y;
                sweep.count = 1;
                sweep.line = line(sweep.x, sweep.y, 'Parent', obj.axesHandle, 'Color', obj.sweepColor);
                obj.sweeps{end + 1} = sweep;
            else
                sweep = obj.sweeps{sweepIndex};
                sweep.y = (sweep.y * sweep.count + y) / (sweep.count + 1);
                sweep.count = sweep.count + 1;
                set(sweep.line, 'YData', sweep.y);
                obj.sweeps{sweepIndex} = sweep;
            end

            ylabel(obj.axesHandle, units, 'Interpreter', 'none');
        end

    end

    methods (Access = private)

        function onSelectedStoreSweeps(obj, ~, ~)
            obj.storeSweeps();
        end
        
        function storeSweeps(obj)
            obj.clearSweeps();
            
            store = obj.sweeps;
            for i = 1:numel(obj.sweeps)
                store{i}.line = copyobj(obj.sweeps{i}.line, obj.axesHandle);
                set(store{i}.line, ...
                    'Color', obj.storedSweepColor, ...
                    'HandleVisibility', 'off');
            end
            obj.storedSweeps(store);
        end
        
        function onSelectedClearSweeps(obj, ~, ~)
            obj.clearSweeps();
        end
        
        function clearSweeps(obj)
            stored = obj.storedSweeps();
            for i = 1:numel(stored)
                delete(stored{i}.line);
            end
            
            obj.storedSweeps([]);
        end

    end
    
    methods (Static)

        function sweeps = storedSweeps(sweeps)
            % This method stores sweeps across figure handlers.

            persistent stored;
            if nargin > 0
                stored = sweeps;
            end
            sweeps = stored;
        end

    end

end
