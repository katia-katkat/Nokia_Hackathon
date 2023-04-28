----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:29:00 04/22/2023 
-- Design Name: 
-- Module Name:    RGB_GRAY - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RGB_GRAY is
PORT(i_clk : in std_logic;
     i_rst :  in std_logic;
	  i_enb:  in std_logic;
	  i_RGB: in unsigned(7 downto 0);
	  o_gray : out unsigned(7 downto 0);
	  o_valid : out std_logic
	  );
end RGB_GRAY;
architecture Behavioral of RGB_GRAY is
constant R_weight : unsigned(18 downto 0) := "0100110010001011010";
constant B_weight : unsigned(18 downto 0) := "0001110100101111001";
constant G_weight : unsigned(18 downto 0) := "1001011001000101101";
type matrice is array(0 to 80) of unsigned( 7 downto 0);
signal R, B, G, Gr: matrice ; 
signal count_all : integer range 0 to 81 := 0;
signal count_RGB : integer range 0 to 2 := 0;
signal start : std_logic := '0';
type convert is(IDLE,RGB,GRAY,SEND);
signal state : convert;

begin
process(i_clk) 
variable result : unsigned(26 downto 0);
begin 
if rising_edge(i_clk) then 
	if i_rst = '1' then
		o_gray <= (others =>'0');
		o_valid <= '0';
		state <= RGB;
	
	else
		
		case state  is 

			when IDLE => 
				o_valid <= '0';
			   state <= IDLE;
				
			when RGB => 
				if count_all < 81 then 
					if i_enb = '1' then 
							case count_RGB is 
								when 0 => R(count_all) <= i_RGB;count_RGB <= count_RGB  + 1;
								when 1 => G(count_all) <= i_RGB;count_RGB <= count_RGB  + 1;
								when 2 => B(count_all) <= i_RGB;count_RGB <= 0; count_all <= count_all + 1;
							end case;
							state <= RGB;
					end if;
				else 
					count_all <= 0;
					state <= GRAY;
				end if;
				
			 when GRAY =>
				o_valid <= '0';
				if count_all < 81 then 
					result := (R(count_all) * R_weight) +  (G(count_all) * G_weight) +  (B(count_all) * B_weight);
					Gr(count_all) <= result(26 downto 19) + ("0000000"&result(18))  ;
					count_all <= count_all + 1;
					state <= GRAY;
				else 
					count_all <= 0;
					state <= SEND;
				end if;
				
			 when SEND =>
			  if count_all < 81 then 
				o_valid <= '1';
				o_gray <= Gr(count_all) ;
				count_all <= count_all + 1;
				state <= SEND;
			  else 
				count_all <= 0;
				o_valid <= '0';
				state <= IDLE;
				end if;
		 end case;
	end if;
end if;
end process;

end Behavioral;

