classdef ResponseStatisticFigure < symphonyui.core.FigureHandler
    
    properties (SetAccess = private)
        device
        measurementFcn
        measurementUnits
        measurementRegion
        baselineRegion
        markerColor
    end
    
    properties (Access = private)
        axesHandle
        markers
    end
    
    methods
        
        function obj = ResponseStatisticFigure(device, measurementFcn, varargin)
            obj@symphonyui.core.FigureHandler(device.name);
            
            co = get(groot, 'defaultAxesColorOrder');
            
            ip = inputParser();
            ip.addParameter('measurementUnits', '', @(x)ischar(x));
            ip.addParameter('measurementRegion', [], @(x)isnumeric(x) || isvector(x));
            ip.addParameter('baselineRegion', [], @(x)isnumeric(x) || isvector(x));
            ip.addParameter('markerColor', co(1,:), @(x)ischar(x) || isvector(x));
            ip.parse(varargin{:});
            
            obj.device = device;
            obj.measurementFcn = measurementFcn;
            obj.measurementUnits = ip.Results.measurementUnits;
            obj.measurementRegion = ip.Results.measurementRegion;
            obj.baselineRegion = ip.Results.baselineRegion;
            obj.markerColor = ip.Results.markerColor;
            
            obj.createUi();
        end
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle, 'epoch');
            ylabel(obj.axesHandle, obj.measurementUnits, 'Interpreter', 'none');
            
            obj.setTitle([obj.device.name ' Statistics (' func2str(obj.measurementFcn) ')']);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandle, t);
        end
        
        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device)
                error(['Epoch does not contain a response for ' obj.device.name]);
            end
            
            response = epoch.getResponse(obj.device);
            quantities = response.getData();
            rate = response.sampleRate.quantityInBaseUnits;
            
            msToPts = @(t)max(round(t / 1e3 * rate), 1);
            
            if ~isempty(obj.baselineRegion)
                x1 = msToPts(obj.baselineRegion(1));
                x2 = msToPts(obj.baselineRegion(2));
                baseline = quantities(x1:x2);
                quantities = quantities - mean(baseline);
            end
            
            if ~isempty(obj.measurementRegion)
                x1 = msToPts(obj.measurementRegion(1));
                x2 = msToPts(obj.measurementRegion(2));
                quantities = quantities(x1:x2);
            end
            
            result = obj.measurementFcn(quantities);
            if isempty(obj.markers)
                obj.markers = line(1, result, 'Parent', obj.axesHandle, ...
                    'LineStyle', 'none', ...
                    'Marker', 'o', ...
                    'MarkerEdgeColor', obj.markerColor, ...
                    'MarkerFaceColor', obj.markerColor);
            else
                x = get(obj.markers, 'XData');
                y = get(obj.markers, 'YData');
                set(obj.markers, 'XData', [x x(end)+1], 'YData', [y result]);
            end
        end
        
    end
        
end