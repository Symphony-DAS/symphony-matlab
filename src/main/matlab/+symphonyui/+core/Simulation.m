classdef Simulation < handle
    % A Simulation is an algorithm that simulates data acquired by data acquisition hardware.
    %
    % To write a new simulation:
    %   1. Subclass Simulation
    %   2. Implement the run method to return simulated "acquired" data.
    
    methods (Abstract)
        inputMap = run(obj, daq, outputMap, timeStep);
    end
    
end

