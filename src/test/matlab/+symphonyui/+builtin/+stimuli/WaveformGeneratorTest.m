classdef WaveformGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = symphonyui.builtin.stimuli.WaveformGenerator();
            gen.waveshape = 0:0.2:100;
            gen.sampleRate = 200;
            gen.units = 'units';
            obj.generator = gen;
        end
        
    end
    
    methods (Test)
        
        function testGenerate(obj)
            import matlab.unittest.constraints.*;
            
            gen = obj.generator;
            stim = gen.generate();
            
            obj.verifyEqual(stim.sampleRate.quantityInBaseUnits, gen.sampleRate);
            obj.verifyEqual(stim.sampleRate.baseUnits, 'Hz');
            obj.verifyEqual(stim.units, gen.units);
            
            [q, u] = stim.getData();
            obj.verifyEqual(q, gen.waveshape, 'AbsTol', 1e-12);
            obj.verifyEqual(u, gen.units);
        end
        
    end
    
end

