function [string, onset, rt] = EchoCueResp(windowPtr, cue, msg, left, right, varargin)
KbName('UnifyKeyNames')
HideCursor();
% string = EchoCue Resp(window, cue, msg, left, right, [KbHandler], dev [spacing], [duration],[answers],[textColor], [bgColor] )

% REQUIRED ARGUMENTS
%
% Get a string typed at the keyboard. Entry is terminated by <return> or
% <enter>. Adapted from GetEchoString, part of the psychtoolbox-basic set
% of functions, distributed with psychtoolbox
%
% Typed characters are displayed in the window. The delete or backspace key
% is handled correctly, ie., it erases the last typed character. Useful for
% i/o in a Screen window.
%
% 'window' = Window to draw to. 
%
% 'cue' = A string to draw on the left half. Can be blank (i.e. the empty
% vector []), but argument cannot be completely left out. 
% NOTE: EMPTY  VECTOR USAGE IS UNTESTED!!!!!!!!!!!!
%
% 'msg' = A message string displayed to  prompt for input. Can be blank 
% (i.e. the empty vector []), but argument cannot be completely left out. 
% NOTE: EMPTY  VECTOR USAGE IS UNTESTED!!!!!!!!!!!! 
%
% 'left' = coordinate positions for region where cue word is placed (i.e.
% left side). Defined by [x1,y1,x2,y2] vector where (x1,y1) is the top 
% left vectice of the rectangular region and (x2,y2) is the bottom right
% vertice of the rectangular region.
%
% 'right' = coordinate positions for region where target input is placed (i.e.
% right side). Defined by [x1,y1,x2,y2] vector where (x1,y1) is the top 
% left vectice of the rectangular region and (x2,y2) is the bottom right
% vertice of the rectangular region. 
%
% OPTIONAL ARGUMENTS
%
% 'KbHandler' = a string specifying the the psychtoolbox key press handling 
% function you want to use. Can be 'KbQueue' (the default),
% 'KbCheck', 'GetChar' or 'Robot'. Using 'Robot' requires
% using an instance of the Java robot class, so it is not suitable for the matlab --no-jvm environment
% and forces the use of KbQueue to handle presses from the robot. 
%
% 'dev' = device number of connected keyboard you want to use 
%
% 'Spacing' = 
%
% 'duration' = numeric scalar value which determines how long input will be
% accepted for. Default is 'inf', which allows for an infinite responding
% period.
%
%
% 'answer' = a character vector which the Java robot will type in. Default
% is [], as 
% 
% 'textColor' = Color to use for drawing the text. 
% 'bgColor' = Background color for text. By default, the background is transparent. If a non-empty
% bgColor value is specified it will be used. The current alpha blending
% setting will affect the appearance of the text if 'bgColor' is specified!

% See also: GetNumber, GetString, GetEchoNumber


if nargin > 12
    error('EchoCueResp:EchoCueResp:TooManyInputs', ...
            'accepts at most 12 argument inputs');
end

optargs = {'KbQueue',[], 35, inf, [], @dummy, {}, Screen('TextColor', windowPtr), []};
optargs(1:length(varargin)) = varargin;
[KbHandler,dev, spacing,duration, answer, drawExtra, params, textColor, bgColor] = optargs{:}; %#ok<ASGLU>

% If RobotEchoHandler is used, check that robot and answer arguments are
% given
if strcmp(KbHandler,'Robot') && isempty(answer)
     error('EchoCueResp:EchoCueResp:MissingRobotInputs', ...
            'Use of RobotEchoHandler requires optional arguments ''robot'' and ''answer'' to be specified');
end

% Enable user defined alpha blending if a text background color is
% specified. This makes text background colors actually work, e.g., on OSX:
if ~isempty(bgColor)
    oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux); 
end

%% ------------- Drawing and Writing --------------------------------------
DisableKeysForKbCheck([9,20,27,32,37,39,44,46,48:57,93,160:165,188,190,191]);
delim=' - ';
string=msg;
onset = draw(cue,delim,string,drawExtra) ;% Write the initial message
string='';
KbHandler=eval(['@' KbHandler '_EchoHandler']);
[string, rt] = KbHandler(string);

%% ------------ Cleanup before going home -------------------------------------------------------------
if ~isempty(bgColor)   % Restore text alpha blending state if it was altered:
    Screen('Preference', 'TextAlphaBlending', oldalpha);
end 
DisableKeysForKbCheck([]);
return

%% ------------- KbHandler Functions ------------------------------------------------------------------

function [string, fliprt]= GetChar_EchoHandler(string) %#ok<DEFNU>
% listen_GetCharStyle
    while true
        char = GetChar;
        [string, dobreak] = checkchar(char,string);
        if dobreak
            break
        else
           fliprt = draw(cue,delim,string,drawExtra);
        end
    end
    ListenChar(0);
end    


function [string, fliprt] = KbCheck_EchoHandler(string) %#ok<DEFNU>
% listen_KbCheckStyle 
    timer=0;
    untilTime = GetSecs + duration;
    tic = GetSecs;       
    while true
        char = GetKbChar(dev,untilTime);
        [string, dobreak] = checkchar(char,string);
        if dobreak
            fliprt = GetSecs;
            break
        else
            fliprt = draw(cue,delim,string,drawExtra);
        end
        toc = GetSecs;
        timer = timer + (toc-tic);
        untilTime = GetSecs+(duration-timer);
    end
    ListenChar(0);    
end

function [string, rt]=KbQueue_EchoHandler(string) %#ok<DEFNU>
% listen_KbQueueStyle
    time = GetSecs;
    untilTime = GetSecs + duration;
    rt=nan(1,2);
    KbQueueStart(dev);
    FP = true;
    while time < untilTime;
        [ ~, firstPress]=KbQueueCheck(dev);
        char = KbName(firstPress);
        if ~isempty(char)
            KbQueueFlush(dev);
            [string, dobreak] = checkchar_cell(char,string);
            if dobreak
                break
            else
                if FP
                    rt(1) = min(firstPress(firstPress>0));
                    FP=false;
                else
                    rt(2) = max(firstPress(firstPress>0));
                end
                draw(cue,delim,string,drawExtra);
            end
        end
        time = GetSecs;
    end
    KbQueueStop(dev);
    
end    

function [string, rt]=Robot_EchoHandler(string) %#ok<DEFNU>
% listen_KbQueueStyle and draw with a robot!!!!
    rob = java.awt.Robot; %#ok<NASGU>
    import java.awt.event.KeyEvent
    press = {'rob.keyPress(KeyEvent.VK_', 'ENTER',');'};
    release = {'rob.keyRelease(KeyEvent.VK_','ENTER',');'};
    time = GetSecs;
    untilTime = time + duration;
    rt=nan(1,2);
    KbQueueStart(dev);
    FP = true;
    for j = 1:length(answer)
        press{2} = upper(answer(j));
        release{2} = upper(answer(j));
        while time < untilTime;
            eval([press{:}]);
            eval([release{:}])
            [ ~, firstPress]=KbQueueCheck(dev);
            char = KbName(firstPress);
            if ~isempty(char)
                KbQueueFlush(dev);
                string = checkchar_cell(char,string);
                if FP 
                    rt(1) = min(firstPress(firstPress>0));
                    FP=false;
                else
                    rt(2) = max(firstPress(firstPress>0));
                end
                draw(cue,msg,string,drawExtra);
            end
            time = GetSecs;
            break
        end
    end
    KbQueueStop(dev);
end

%% ---------- checkchar(char) -----------------------------------------------------------------
    function [string, dobreak] = checkchar(char, string)
        if isempty(char)
            dobreak =1;
        end  
        switch abs(char)
            case {13, 3, 10} % ctrl-C, enter, or return
                dobreak = 1;
            case 8 % backspace
                if ~isempty(string)
                    string=string(1:end-1);              
                end
            otherwise
                string = [string, char]; 
        end
    end
%% --------------- checkchar_cell( {char} ) -------------------------------------------------
    function [string, dobreak] = checkchar_cell(char, string)
        dobreak = 0;
        if isempty(char)
           dobreak =1;
        end    

        if ~iscell(char)
            char ={char(:)'};
        end

        for i=1:length(char)    
            switch char{i}
                case {'Return', 'Enter'}% ctrl-C, enter, or return
                    dobreak =1; 
                case 'BackSpace'
                        % backspace
                    if ~isempty(string)
                        string=string(1:end-1);              
                    end
                otherwise
                    string = [string, char{i}]; %#ok<AGROW>
            end
        end
    end
%% --------------- draw -------------------------------------------------
    function onset = draw(cue,msg,string,drawExtra)
        drawExtra(params{:})
        DrawFormattedText(windowPtr,cue,'right', 'center',[],[],[],[],[],[],left-[0 0 spacing 0]);
        DrawFormattedText(windowPtr,msg, 'center','center');
        DrawFormattedText(windowPtr,string,right(1)+spacing, 'center');
        [~, onset] = Screen('Flip', windowPtr);
    end

    function dummy(varargin)
    end
    
end

