classdef SquareGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = symphonyui.builtin.stimuli.SquareGenerator();
            gen.preTime = 51.2;
            gen.stimTime = 300;
            gen.tailTime = 25;
            gen.amplitude = 140;
            gen.mean = -30;
            gen.period = 100;
            gen.phase = pi/2;
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
            
            timeToPts = @(t)(round(t / 1e3 * gen.sampleRate));
            
            prePts = timeToPts(gen.preTime);
            stimPts = timeToPts(gen.stimTime);
            tailPts = timeToPts(gen.tailTime);
            
            freq = 2 * pi / (gen.period * 1e-3);
            time = (0:stimPts-1) / gen.sampleRate;
            sine = sin(freq * time + gen.phase);
            square(sine > 0) = gen.amplitude;
            square(sine < 0) = -gen.amplitude;
            square = square + gen.mean;
            
            [q, u] = stim.getData();
            obj.verifyEqual(length(q), prePts + stimPts + tailPts);
            obj.verifyEveryDoubleElementEqualTo(q(1:prePts), gen.mean);
            obj.verifyEqual(q(prePts+1:prePts+stimPts), square, 'AbsTol', 1e-12);
            obj.verifyEveryDoubleElementEqualTo(q(prePts+stimPts+1:end), gen.mean);
            obj.verifyEqual(u, gen.units);
        end
        
        function testRegenerate(obj)
            stim = obj.generator.generate();
            obj.verifyStimulusRegenerates(stim);
        end
        
    end
    
end

