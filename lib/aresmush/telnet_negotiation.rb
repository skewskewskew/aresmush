module AresMUSH
  class TelnetNegotiation
    
    def initialize(connection)
      @connection = connection
    end
    
    INTERPRET_AS_CONTROL = 255
    DO = 253
    DONT = 254
    WILL = 251
    WONT = 252
    NOP = 241
    START_SUB_NEGOTIATION = 250
    END_SUB_NEGOTIATION = 240
    REQUEST = 1
    
    CHARSET = 42
    NAWS = 31
    
    def handle_input(data)
      chars = data.split("")

      return data if (chars.length < 2 || chars[0].ord != INTERPRET_AS_CONTROL)
            
      # Get rid of the control code      
      chars.shift
      
      # Start of negotiation sequence
      if (chars[0].ord == START_SUB_NEGOTIATION)
        chars.shift # Ditch the sub-nego flag
          
        negotiation_options = []
        while (chars[0] && chars[0].ord != END_SUB_NEGOTIATION)
          negotiation_options << chars.shift.ord
        end
        chars.shift # Ditch the end-nego flag
                    
        if (negotiation_options[0] == NAWS && negotiation_options.length > 4)
          @connection.window_width = negotiation_options[2]
          @connection.window_height = negotiation_options[4]
        end       
      elsif (chars[0].ord == WILL)
        chars.shift  # Ditch the will code
        op = chars.shift.ord # The code being acknowledged

        # Will charset
        if (op == CHARSET)
          send_telnet_control [ INTERPRET_AS_CONTROL, START_SUB_NEGOTIATION, CHARSET, REQUEST, 32, 'u'.ord, 't'.ord, 'f'.ord, '-'.ord, '8'.ord, INTERPRET_AS_CONTROL, END_SUB_NEGOTIATION ]
        end
      elsif (chars[0].ord == WONT)
        chars.shift # Ditch the won't code
        op = chars.shift.ord
      elsif (chars[0].ord == NOP)
        # Do nothing
        chars.shift
      end
      return handle_input(chars.join)
    end

    def send_naws_request
      send_telnet_control [ INTERPRET_AS_CONTROL, DO, NAWS ]        
    end
    
    def send_charset_request
      send_telnet_control [ INTERPRET_AS_CONTROL, DO, CHARSET ]
    end      
    
    private
    
    def send_telnet_control(data)
      @connection.send_data data.map { |c| c.chr }.join 
    end
  end
end