------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bintobcd is
generic(BINARY_WIDTH: integer  := 8 ;
			DECIMAL_DIGITS: integer := 2);
port(
i_clk : in std_logic ;
i_rst :in std_logic ;
i_binary :in unsigned(BINARY_WIDTH-1 downto 0) ;
i_busy_input :in std_logic ;
i_busy_output :in std_logic ;
i_empty_input:in std_logic ;
i_full_output :in std_logic ;
o_BCD :out unsigned(BINARY_WIDTH-1 downto 0) ;
o_valid_output :out std_logic ;
o_req_input :out std_logic 

);
end bintobcd;

architecture Behavioral of bintobcd is
type state_type is( s_IDLE , s_SEND_REQ, s_GET_DATA, s_SHIFT , s_CHECK_SHIFT, s_ADD,s_CHECK_DIGIT,s_DONE );
signal state : state_type;
signal r_BCD :unsigned(BINARY_WIDTH-1 downto 0) := (others => '0');
signal r_binary: unsigned (BINARY_WIDTH-1 downto 0) := (others => '0');
signal r_digit_index :integer := 0;
signal bcd_r :integer := 0;

signal r_loop_count :integer range 0 to 7 := 0;
begin

process(i_clk )
begin
if rising_edge(i_clk) then 
 if i_rst = '1' then
		o_req_input <= '0';
		state <= s_IDLE ;
 else 
 case state is
    when s_IDLE => 
		 o_valid_output <= '0';
		 if (i_busy_input= '0' and i_empty_input= '0' ) then
				o_req_input <= '1';
				state <= s_SEND_REQ ;
		 else 
				state <= s_IDLE ;
		 end if ;
		 
	 when s_SEND_REQ =>
		 o_req_input <= '0';
		 state <= s_GET_DATA;
		 
	 when s_GET_DATA =>
	  	 r_binary <= i_binary;
		 state <= s_SHIFT ;
	
		 
	when s_SHIFT =>
		r_BCD <=  shift_left(r_BCD, 1);
		r_BCD(0) <= r_binary(7);
		r_binary <= shift_left(r_binary , 1);
		state <= s_CHECK_SHIFT ;
		 
	when s_CHECK_SHIFT =>
			if(r_loop_count = BINARY_WIDTH-1) then 
			   r_loop_count <= 0;
				state <= s_DONE;
			else 
				r_loop_count <= r_loop_count + 1;
				state <= s_ADD;
			end if;
	
	when s_ADD =>
			if  bcd_r > 4 then 
				r_BCD((4*(r_digit_index+1) - 1) downto 4*r_digit_index ) <= r_BCD( (4*(r_digit_index+1) - 1) downto 4*r_digit_index ) + "0011";
			end if; 
			state <= s_CHECK_DIGIT;
	
	when s_CHECK_DIGIT =>
			if r_digit_index /= DECIMAL_DIGITS -1 then 
				state <= s_ADD ;
				r_digit_index <= r_digit_index + 1;
			else 
				state <= s_SHIFT ;
				r_digit_index <= 0;
			end if ;
	when s_DONE =>
		if( i_full_output = '0' and i_busy_output = '0') then
			o_valid_output <= '1';
			o_BCD <= r_BCD;
			state <= s_IDLE;
		else 
			state <= s_DONE;		
		end if;
	end case;
	end if;
	end if;
	end process;
bcd_r <= to_integer(r_BCD( (4*(r_digit_index+1) - 1) downto 4*r_digit_index ));
		  
end Behavioral;

