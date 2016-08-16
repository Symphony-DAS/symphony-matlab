classdef NiDaqController < symphonyui.core.DaqController
    % Manages a National Instruments DAQ interface
    
    methods
        
        function obj = NiDaqController(deviceName)
            NET.addAssembly(which('NIDAQInterface.dll'));
            
            if nargin < 1
                enum = Symphony.Core.EnumerableExtensions.Wrap(NI.NIDAQController.AvailableControllers());
                e = enum.GetEnumerator();
                if ~e.MoveNext()
                    error('Unable to find any National Instruments devices. Make sure your device is listed in NI MAX and try again.');
                end
                deviceName = char(e.Current().DeviceName);
            end
            
            cobj = NI.NIDAQController(deviceName);
            obj@symphonyui.core.DaqController(cobj);
        end
        
    end
    
end

