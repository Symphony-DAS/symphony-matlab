classdef AppData < handle
    
    events
        SetRig
        SetExperiment
        SetControllerState
    end
    
    properties (SetAccess = private)
        rig
        experiment
        controller
    end
    
    properties (Access = private)
        listeners
    end
    
    methods
        
        function obj = AppData(controller)
            if nargin < 1
                controller = SymphonyUI.Models.Controller();
            end
            
            obj.controller = controller;
            
            addlistener(controller, 'state', 'PostSet', @(h,d)notify(obj, 'SetControllerState'));
            addlistener(controller, 'rig', 'PostSet', @(h,d)notify(obj, 'SetRig'));
        end
        
        function setRig(obj, r)
            obj.controller.setRig(r);
        end
        
        function r = get.rig(obj)
            r = obj.controller.rig;
        end
        
        function setExperiment(obj, e)
            obj.experiment = e;
            notify(obj, 'SetExperiment');
        end
        
    end
    
end

