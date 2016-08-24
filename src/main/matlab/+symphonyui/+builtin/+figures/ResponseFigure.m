classdef ResponseFigure < symphonyui.core.FigureHandler
    % Plots the response of a specified device in the most recent epoch.

    properties (SetAccess = private)
        device
        sweepColor
        storedSweepColor
    end

    properties (Access = private)
        axesHandle
        sweep
    end

    methods

        function obj = ResponseFigure(device, varargin)
            co = get(groot, 'defaultAxesColorOrder');

            ip = inputParser();
            ip.addParameter('sweepColor', co(1,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor', 'r', @(x)ischar(x) || isvector(x));
            ip.parse(varargin{:});

            obj.device = device;
            obj.sweepColor = ip.Results.sweepColor;
            obj.storedSweepColor = ip.Results.storedSweepColor;

            obj.createUi();
            
            stored = obj.storedSweep();
            if ~isempty(stored)
                stored.line = line(stored.x, stored.y, 'Parent', obj.axesHandle, 'Color', obj.storedSweepColor);
            end
            obj.storedSweep(stored);
        end

        function createUi(obj)
            import appbox.*;

            toolbar = findall(obj.figureHandle, 'Type', 'uitoolbar');
            storeSweepButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Store Sweep', ...
                'Separator', 'on', ...
                'ClickedCallback', @obj.onSelectedStoreSweep);
            setIconImage(storeSweepButton, symphonyui.app.App.getResource('icons', 'sweep_store.png'));

            clearSweepsButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Clear Sweep', ...
                'ClickedCallback', @obj.onSelectedClearSweep);
            setIconImage(clearSweepsButton, symphonyui.app.App.getResource('icons', 'sweep_clear.png'));
            
            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle, 'sec');

            obj.setTitle([obj.device.name ' Response']);
        end

        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandle, t);
        end

        function clear(obj)
            cla(obj.axesHandle);
            obj.sweep = [];
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
            if isempty(obj.sweep)
                obj.sweep.x = x;
                obj.sweep.y = y;
                obj.sweep.line = line(obj.sweep.x, obj.sweep.y, 'Parent', obj.axesHandle, 'Color', obj.sweepColor);
            else
                obj.sweep.x = x;
                obj.sweep.y = y;
                set(obj.sweep.line, 'XData', obj.sweep.x, 'YData', obj.sweep.y);
            end
            ylabel(obj.axesHandle, units, 'Interpreter', 'none');
        end

    end

    methods (Access = private)

        function onSelectedStoreSweep(obj, ~, ~)
            obj.storeSweep();
        end
        
        function storeSweep(obj)
            obj.clearSweep();
            
            store = obj.sweep;
            if ~isempty(store)
                store.line = copyobj(obj.sweep.line, obj.axesHandle);
                set(store.line, ...
                    'Color', obj.storedSweepColor, ...
                    'HandleVisibility', 'off');
            end
            obj.storedSweep(store);
        end
        
        function onSelectedClearSweep(obj, ~, ~)
            obj.clearSweep();
        end
        
        function clearSweep(obj)
            stored = obj.storedSweep();
            if ~isempty(stored)
                delete(stored.line);
            end
            
            obj.storedSweep([]);
        end

    end
    
    methods (Static)

        function sweep = storedSweep(sweep)
            % This method stores a sweep across figure handlers.

            persistent stored;
            if nargin > 0
                stored = sweep;
            end
            sweep = stored;
        end

    end

end
