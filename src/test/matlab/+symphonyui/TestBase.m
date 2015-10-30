classdef TestBase < matlab.unittest.TestCase
    
    properties
    end
    
    methods (TestClassSetup)
        
        function classSetup(obj)
            import matlab.unittest.fixtures.PathFixture;
            
            rootPath = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '..');
            
            core = fullfile(rootPath, 'lib', 'Core Framework');
            ui = fullfile(rootPath, 'src', 'main', 'matlab');
            
            obj.applyFixture(PathFixture(core));
            obj.applyFixture(PathFixture(ui));
            
            NET.addAssembly(which('Symphony.Core.dll'));
        end
        
    end
    
    methods
        
        function verifyDatetimesEqual(obj, actual, expected)
            obj.verifyEqual(actual.Year, expected.Year);
            obj.verifyEqual(actual.Month, expected.Month);
            obj.verifyEqual(actual.Day, expected.Day);
            obj.verifyEqual(actual.Hour, expected.Hour);
            obj.verifyEqual(actual.Minute, expected.Minute);
            obj.verifyEqual(actual.Second, expected.Second);
            obj.verifyEqual(actual.Minute, expected.Minute);
            
            actual.Format = 'ZZZZZ';
            expected.Format = 'ZZZZZ';
            obj.verifyEqual(char(actual), char(expected));
        end
        
        function verifyCellsAreEquivalent(obj, actual, expected)
            obj.verifyEqual(numel(actual), numel(expected));
            
            for i = 1:numel(actual)
                equal = zeros(1, numel(expected));
                for j = 1:numel(expected)
                    equal(j) = isequal(actual{i}, expected{j});
                end
                obj.verifyTrue(any(equal));
            end     
        end
        
    end
    
end

