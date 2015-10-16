classdef DirectCurrentGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = symphonyui.builtin.stimuli.DirectCurrentGenerator();
            gen.time = 3.1;
            gen.offset = -60;
            gen.sampleRate = 100;
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
            
            timeToPts = @(t)(round(t * gen.sampleRate));
            
            pts = timeToPts(gen.time);
            
            [q, u] = stim.getData();
            obj.verifyEqual(length(q), pts);
            obj.verifyEveryDoubleElementEqualTo(q, gen.offset);
            obj.verifyEqual(u, gen.units);
        end
        
    end
    
end

