classdef ResponseStatisticsFigure < symphonyui.core.FigureHandler
    
    properties (SetAccess = private)
        device
        measurementCallbacks
        measurementRegion
        baselineRegion
    end
    
    properties (Access = private)
        axesHandles
        markers
    end
    
    methods
        
        function obj = ResponseStatisticsFigure(device, measurementCallbacks, varargin)
            if ~iscell(measurementCallbacks)
                measurementCallbacks = {measurementCallbacks};
            end
            
            ip = inputParser();
            ip.addParameter('measurementRegion', [], @(x)isnumeric(x) || isvector(x));
            ip.addParameter('baselineRegion', [], @(x)isnumeric(x) || isvector(x));
            ip.parse(varargin{:});
            
            obj.device = device;
            obj.measurementCallbacks = measurementCallbacks;
            obj.measurementRegion = ip.Results.measurementRegion;
            obj.baselineRegion = ip.Results.baselineRegion;
            
            obj.createUi();
        end
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            for i = 1:numel(obj.measurementCallbacks)
                obj.axesHandles(i) = subplot(numel(obj.measurementCallbacks), 1, i, ...
                    'Parent', obj.figureHandle, ...
                    'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                    'XTickMode', 'auto', ...
                    'XColor', 'none');
                ylabel(obj.axesHandles(i), func2str(obj.measurementCallbacks{i}));
            end
            set(obj.axesHandles(end), 'XColor', get(groot, 'defaultAxesXColor'));
            xlabel(obj.axesHandles(end), 'epoch');
            
            obj.setTitle([obj.device.name ' Response Statistics']);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandles(1), t);
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
            
            for i = 1:numel(obj.measurementCallbacks)
                fcn = obj.measurementCallbacks{i};
                result = fcn(quantities);
                if numel(obj.markers) < i
                    colorOrder = get(groot, 'defaultAxesColorOrder');
                    color = colorOrder(mod(i - 1, size(colorOrder, 1)) + 1, :);
                    obj.markers(i) = line(1, result, 'Parent', obj.axesHandles(i), ...
                        'LineStyle', 'none', ...
                        'Marker', 'o', ...
                        'MarkerEdgeColor', color, ...
                        'MarkerFaceColor', color);
                else
                    x = get(obj.markers(i), 'XData');
                    y = get(obj.markers(i), 'YData');
                    set(obj.markers(i), 'XData', [x x(end)+1], 'YData', [y result]);
                end
            end
        end
        
    end
        
end