function tests = makeInputHandlerFcn_tests
    tests = functiontests(localfunctions);

end

function test_input_equals_output(testCase) % must start with test
	handler = makeInputHandlerFcn('free_response_robot');
    input = 'hello world';
    output = '';
    while true
        key_pressed = handler([], input);
        if key_pressed == 13 %Enter key
            break
        elseif key_pressed == 32 % Space Bar
            character = ' ';
        else
            character = KbName(key_pressed);
        end
        output = [output character]; %#ok<AGROW>
    end
    testCase.verifyEqual(input, output)
end

function setupOnce(testCase)  % do not change function name
    file_path = fileparts(mfilename('fullpath'));
    file_path = strsplit(file_path, filesep);
    root_dir_index = find(strcmp(file_path, 'PTB-utils'), 1);
    new_path_locations = genpath(fullfile(file_path{1:root_dir_index}));
    new_path_locations = strsplit(new_path_locations,';');
    new_path_locations = new_path_locations(1:end-1); % Remove trailing empty char
    is_in_git_folder = cellfun(@isempty, regexpi(new_path_locations, '\.git|test'));
    new_path_locations = new_path_locations(is_in_git_folder)';
    testCase.TestData.orig_path = addpath(new_path_locations{:});
    
    KbName('UnifyKeyNames')
end

function teardownOnce(testCase)  % do not change function name
    path(testCase.TestData.orig_path)
end

%% Optional fresh fixtures  
function setup(testCase)  % do not change function name
% keysOfInterest = zero(1,256);
ListenChar(-1)
KbQueueCreate([]);
KbQueueStart([]);
end

function teardown(testCase)  % do not change function name
KbQueueRelease([]);
ListenChar(0);
end