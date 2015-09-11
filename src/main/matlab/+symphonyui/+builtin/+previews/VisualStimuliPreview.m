classdef VisualStimuliPreview < symphonyui.core.ProtocolPreview
    
    properties
        createStimuliFcn
        getClearColorFcn
    end
    
    properties (Access = private)
        log
        canvas
        axes
    end
    
    methods
        
        function obj = VisualStimuliPreview(panel, createStimuliFcn, getClearColorFcn)
            if nargin < 3
                getClearColorFcn = @()0;
            end
            
            obj@symphonyui.core.ProtocolPreview(panel);
            obj.createStimuliFcn = createStimuliFcn;
            obj.getClearColorFcn = getClearColorFcn;
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.createUi();
        end
        
        function createUi(obj)
            window = Window([640, 480], false, Monitor(1), 'Visible', GL.FALSE);
            obj.canvas = Canvas(window, 'DisableDwm', false);
            obj.axes = axes( ...
                'Parent', obj.panel, ...
                'Position', [0 0 1 1], ...
                'XColor', 'none', ...
                'YColor', 'none', ...
                'Color', 'none'); %#ok<CPROP>
            obj.update();
        end
        
        function update(obj)
            try
                obj.canvas.setClearColor(obj.getClearColorFcn());
            catch x
                text(0.5, 0.5, 'Cannot set clear color', ...
                    'Parent', obj.axes, ...
                    'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                    'HorizontalAlignment', 'center');
                obj.log.debug(x.message, x);
                return;
            end
            
            obj.canvas.clear();
            
            try
                stimuli = obj.createStimuliFcn();
            catch x
                text(0.5, 0.5, 'Cannot create stimuli', ...
                    'Parent', obj.axes, ...
                    'FontName', get(obj.panel, 'DefaultUicontrolFontName'), ...
                    'FontSize', get(obj.panel, 'DefaultUicontrolFontSize'), ...
                    'HorizontalAlignment', 'center');
                obj.log.debug(x.message, x);
                return;
            end
            
            for i = 1:numel(stimuli)
                stimuli{i}.init(obj.canvas);
                stimuli{i}.draw();
            end
            
            data = obj.canvas.getPixelData();
            imshow(data, 'Parent', obj.axes);
            set(obj.axes, ...
                'XColor', 'none', ...
                'YColor', 'none', ...
                'Color', 'none');
        end
        
    end
    
end

