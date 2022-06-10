function [obj] = encodeRecordingLoop(obj)
% function  [obj] = decodePlaybackLoop(obj)
% Unpack ReaStream Frame and Play Audio

    % Control Flags
    global STATE_IN_LOOP_FLAG_;% Global interupt flag
    global FLUSH_UDP_BUFFER_FLAG_; 
    FLUSH_UDP_BUFFER_FLAG_ = false;
    STATE_FLAG_ = obj.PROCESSING_ON_STATE_;

    if obj.DEBUG_ACTIVEKEYBOARD_INTERRUPT_FLAG
        figh = gcbf;
        if isempty(figh)
            figh = figure('units','normalized','position',[0,0,0.01,0.01]*2);
        end
        figh.UserData = obj;
%         figh.WindowStyle = 'alwaysontop';
        set(figh,'WindowKeyPressFcn',@onKeyboardPressCallback);
    end

    % Playback Settings
    coder.varsize('recordBuffer');
    recordBuffer = single([]);
    
    % Frame count
    f=1;
    % Loop
    while STATE_IN_LOOP_FLAG_ && not(STATE_FLAG_ == obj.EXIT_STATE_)% External and Internal interupt flags

        % Get audio frame/ Read reastream frame
        [Frame,STATE_FLAG_] = getReaStreameFrame(obj);   

        byteArray = rsFrame2UDPbyteArray(Frame);

        sendUDPbuffer(obj,byteArray);

        if obj.DEBUG_STORE_FRAME_FLAG
            % Single frame or cumulative
            obj.FrameBuffer = Frame;
        end

        % This will force update the UI but not unless there is normal
        % transmission frames
        
        if mod(f,obj.PacketsPerUIrefresh)==0
            if coder.target('MATLAB')
                drawnow;% Refresh UI rate   
            end
        end 
        
        % Control logic Check flags
        if (STATE_FLAG_ == obj.SKIP_FRAME_STATE_) || (STATE_FLAG_ == obj.NO_TRANSMISSION_STATE_)
            continue;
        end    

        % External interupt switch!
        if not(STATE_IN_LOOP_FLAG_) 
            if (STATE_FLAG_ == obj.NO_TRANSMISSION_STATE_)
                disp(' --- Disconnect due to empty transmission! --- ');
            end
            break;
        end

        %  IGNORE+++START
        if coder.target('MATLAB') && obj.DEBUG_SCOPE_SHOW_FLAG
            updateScopeInLoopScript;
        end
        %  IGNORE+++END



            % Debug %  IGNORE+++START
            if coder.target('MATLAB')  
                % Debug Scripts
%                 debugInLoopScript;
            end
            %  IGNORE+++END

        % Increment frame only when the whole routine is complete
        f = f+1;
    end
end     