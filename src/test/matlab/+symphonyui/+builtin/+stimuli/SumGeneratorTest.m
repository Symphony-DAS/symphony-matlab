classdef SumGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen1 = symphonyui.builtin.stimuli.PulseGenerator();
            gen1.preTime = 50;
            gen1.stimTime = 430.2;
            gen1.tailTime = 70;
            gen1.amplitude = 100;
            gen1.mean = -60;
            gen1.sampleRate = 100;
            gen1.units = 'units';
            stim1 = gen1.generate();
            
            gen2 = symphonyui.builtin.stimuli.RampGenerator();
            gen2.preTime = 50;
            gen2.stimTime = 430.2;
            gen2.tailTime = 70;
            gen2.amplitude = 100;
            gen2.mean = -60;
            gen2.sampleRate = 100;
            gen2.units = 'units';
            stim2 = gen2.generate();
            
            stim3 = gen2.generate();
            
            gen = symphonyui.builtin.stimuli.SumGenerator();
            gen.stimuli = {stim1, stim2, stim3};
            obj.generator = gen;
        end
        
    end
    
    methods (Test)
        
        function testGenerate(obj)
            import matlab.unittest.constraints.*;
            
            gen = obj.generator;
            sumStim = gen.generate();
            
            stim1Data = gen.stimuli{1}.getData();
            stim2Data = gen.stimuli{2}.getData();
            stim3Data = gen.stimuli{3}.getData();
            sumData = sumStim.getData();
            
            obj.verifyEqual(sumData, stim1Data + stim2Data + stim3Data, 'AbsTol', 1e-12);
        end
        
    end
    
end

