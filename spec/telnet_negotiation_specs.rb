$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require "aresmush"

module AresMUSH

  describe TelnetNegotiation do

    before do
      @connection = double
      @negotaitor = TelnetNegotiation.new(@connection)
    end
      
    describe "NAWS" do
      it "should ignore a telnet NAWS control code" do
        data = [ 255, 251, 31, 0x30, 0x31, 0x32 ]
        str = data.map { |d| d.chr }.join
        @negotaitor.handle_input(str).should eq "012"
      end
      
      it "should shandle a NAWS response with the window size" do
        data = [ 255, 250, 31, 0, 80, 0, 24, 255, 240, 0x30, 0x31, 0x32 ]
        str = data.map { |d| d.chr }.join
        @connection.should_receive(:window_width=).with(80)
        @connection.should_receive(:window_height=).with(24)
        @negotaitor.handle_input(str).should eq "012"
      end
    end
    
    describe "Charset" do
      it "should send a charset instruction if the client will do charset commands" do
        data = [ 255, 251, 42, 0x30, 0x31, 0x32 ]
        str = data.map { |d| d.chr }.join
        @connection.should_receive(:send_data).with( [ 255, 250, 42, 1, 32, 'u'.ord, 't'.ord, 'f'.ord, '-'.ord, '8'.ord, 255, 240 ] )
        @negotaitor.handle_input(str).should eq "012"
      end
    end
  end
end