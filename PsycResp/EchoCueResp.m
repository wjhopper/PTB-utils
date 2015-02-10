function [string, final_fliprt] = EchoCueResp(windowPtr, cue, msg, left, right, varargin)
global deviceIndex
KbName('UnifyKeyNames')
HideCursor();
% string = EchoCue Resp(window, cue, msg, left, right, [KbHandler], [spacing], [duration], [robot], [answers],[textColor], [bgColor] )

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
% 'KbHandler' = character vector specifying the name of psychtoolbox key press handling 
%    function. Can be 'KbQueue' (the default), 'KbCheck',or 'GetChar'.
%
% 'Spacing' = 
%
% 'duration' = numeric scalar value which determines how long input will be
% accepted for. Default is 'inf', which allows for an infinite responding
% period.
%
% 'robot' = logical value which determines whether the function should wait
% for a human user to give input, or whether a Java robot should input the
% answers. Default is false. Useful for debugging. If true, the 'answers' argument must also
% be specified to tell the Java robot what to type!
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

optargs = {'KbQueue',35,  inf, false , [],Screen('TextColor', windowPtr),[]};
optargs(1:length(varargin)) = varargin;
[KbHandler, spacing,duration, robot,answer, textColor, bgColor] = optargs{:}; %#ok<ASGLU>

if robot
   import java.awt.Robot;
   import java.awt.event.*;
   rob=Robot; %#ok<NASGU>
   press = {'rob.keyPress(KeyEvent.VK_', 'ENTER',');'};
   release = {'rob.keyRelease(KeyEvent.VK_','ENTER',');'};
else
   press={''};
   release={''};    
end

% Enable user defined alpha blending if a text background color is
% specified. This makes text background colors actually work, e.g., on OSX:
if ~isempty(bgColor)
    oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux); 
end

%% ------------- Drawing and Writing --------------------------------------
delim=' - ';
string=msg;
draw(cue,delim,string) ;% Write the initial message
string='';

DisableKeysForKbCheck([9,20,27,32,37,39,44,46,48:57,93,160:165,188,190,191]);

switch KbHandler
    case 'GetChar'
        KbQueueRelease(deviceIndex);
        ListenChar(2);
        FlushEvents;        
        [string, final_fliprt]=listen_GetCharStyle(string);
    case 'KbCheck'
        KbQueueRelease(deviceIndex);
        ListenChar(2);
        FlushEvents;
        [string, final_fliprt] = listen_KbCheckStyle(string);        
    case 'KbQueue'
        ListenChar(0);
        KbQueueCreate(deviceIndex);             
        [string, final_fliprt]=listen_KbQueueStyle(string);
end

%% ------------ Cleanup before going home -------------------------------------------------------------
if ~isempty(bgColor)   % Restore text alpha blending state if it was altered:
    Screen('Preference', 'TextAlphaBlending', oldalpha);
end

if strcmp(KbHandler, 'KbQueue')
    KbQueueStop(deviceIndex);
    DisableKeysForKbCheck([]);
else
    ListenChar(0);
    DisableKeysForKbCheck([]);
end

   
return
%% ------------- listening functions ------------------------------------------------------------------

% listen_GetCharStyle
    function [string, fliprt]= listen_GetCharStyle(string)
        while true
            char = GetChar;
            string = checkchar(char,string);
            if dobreak
                break
            else
               fliprt = draw(cue,msg,string);
            end
        end
    end    

 % listen_KbCheckStyle   
    function [string, fliprt] = listen_KbCheckStyle(string)
        timer=0;
        untilTime = GetSecs + duration;
        tic = GetSecs;       
        while true
            char = GetKbChar(deviceIndex,untilTime);
            [string, dobreak] = checkchar(char,string);
            if dobreak
                fliprt = GetSecs;
                break
            else
                fliprt = draw(cue,msg,string);
            end
            toc = GetSecs;
            timer = timer + (toc-tic);
            untilTime = GetSecs+(duration-timer);
        end    
    end

% listen_KbQueueStyle
    function [string, fliprt]=listen_KbQueueStyle(string)
        import java.awt.Robot;
        import java.awt.event.*;
        time = GetSecs;
        untilTime = GetSecs + duration;
        KbQueueStart(deviceIndex);
        if robot
            for j = 1:length(answer)
                press{2} = upper(answer(j));
                release{2} = upper(answer(j));
                while time < untilTime;
                    eval([press{:}]);
                    [ ~, firstPress]=KbQueueCheck(deviceIndex);
                    char = KbName(firstPress);
                    if ~isempty(char)
                        eval([release{:}])
                        KbQueueFlush(deviceIndex);
                        clear firstPress
                        [string, dobreak] = checkchar_cell(char,string);
                        if dobreak
                            fliprt = GetSecs;
                            break
                        else
                            fliprt = draw(cue,msg,string);
                            break
                        end
                    end
                    time = GetSecs;
                end
            end
        else
            while time < untilTime;
                [ ~, firstPress]=KbQueueCheck(deviceIndex);
                char = KbName(firstPress);
                if ~isempty(char)
                    KbQueueFlush(deviceIndex);
                    clear firstPress
                    [string, dobreak] = checkchar_cell(char,string);
                    if dobreak
                        fliprt = GetSecs;
                        break
                    else
                        fliprt = draw(cue,msg,string);
                    end
                    time = GetSecs;
                else
                    time = GetSecs;
                end
            end              
        end    
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
%% --------------- checkchar_cell() -------------------------------------------------
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
    function fliprt = draw(cue,msg,string)
        DrawFormattedText(windowPtr,cue,'right', 'center',[],[],[],[],[],[],left-[0 0 spacing 0]);
        DrawFormattedText(windowPtr,msg, 'center','center');
        DrawFormattedText(windowPtr,string,right(1)+spacing, 'center');
        fliprt = Screen('Flip', windowPtr);
    end    
    
end

