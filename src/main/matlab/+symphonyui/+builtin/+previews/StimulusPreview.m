classdef StimulusPreview < symphonyui.core.ProtocolPreview
    
    properties
        createStimulusFcn
    end
    
    properties (Access = private)
        log
        axes
    end
    
    methods
        
        function obj = StimulusPreview(panel, createStimulusFcn)
            obj@symphonyui.core.ProtocolPreview(panel);
            obj.createStimulusFcn = createStimulusFcn;
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.createUi();
        end
        
        function createUi(obj)
            obj.axes = axes( ...
                'Parent', obj.panel, ...
                'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto'); %#ok<CPROP>
            xlabel(obj.axes, 'sec');
            obj.update();
        end
        
        function update(obj)
            cla(obj.axes);
            try
                stimulus = obj.createStimulusFcn();
            catch x
                text(0.5, 0.5, 'Cannot create stimulus', ...
                    'Parent', obj.axes, ...
                    'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                    'HorizontalAlignment', 'center');
                obj.log.debug(x.message, x);
                return;
            end
            [quantities, units] = stimulus.getData();
            x = (1:numel(quantities)) / stimulus.sampleRate.quantityInBaseUnits;
            y = quantities;
            line(x, y, 'Parent', obj.axes);
            ylabel(obj.axes, units, 'Interpreter', 'none');
        end
        
    end
    
end

