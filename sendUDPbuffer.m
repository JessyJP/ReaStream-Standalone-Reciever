function [output] = sendUDPbuffer(obj,byteArray)
% function [output] = sendUDPbuffer(obj,bTransmitteryteSize,type)

fwrite(obj.TransmitterUDP,byteArray);
return
%     if  obj.DEBUG_BUFFER_REALTIME_FLAG
        try 
%             obj.TransmitterUDP.write(byteArray,"uint8");
            write(obj.TransmitterUDP,byteArray,"uint8");
        catch
            write(obj.TransmitterUDP,byteArray,"uint8",...
                obj.TransmitterUDP.LocalHost,obj.TransmitterUDP.LocalPort);
        end
%     [output] = write(obj.ReceiverUDP,byteSize,type); 

%     end
    