classdef ResponseFigure < symphonyui.core.FigureHandler

    properties (SetAccess = private)
        device
        sweepColor
        storedSweepColor
    end

    properties (Access = private)
        axesHandle
        sweep
        storedSweep
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

            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
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
                obj.sweep = line(x, y, 'Parent', obj.axesHandle, 'Color', obj.sweepColor);
            else
                set(obj.sweep, 'XData', x, 'YData', y);
            end
            ylabel(obj.axesHandle, units, 'Interpreter', 'none');
        end

    end

    methods (Access = private)

        function onSelectedStoreSweep(obj, ~, ~)
            if ~isempty(obj.storedSweep)
                delete(obj.storedSweep);
            end
            obj.storedSweep = copyobj(obj.sweep, obj.axesHandle);
            set(obj.storedSweep, ...
                'Color', obj.storedSweepColor, ...
                'HandleVisibility', 'off');
        end

    end

end
