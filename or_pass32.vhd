library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity or_pass32 is
Port (
A : in std_logic_vector(31 downto 0);
B : in std_logic_vector(31 downto 0);
SROR : in std_logic;
upper : out std_logic_vector(15 downto 0);
lower : out std_logic_vector(15 downto 0)
);
end or_pass32;
architecture Behavioral of or_pass32 is
begin
process
begin
else
end if;
variable temp_result : std_logic_vector(31 downto 0);
if SROR = '0' then
temp_result := A or B;
temp_result := B;
upper <= temp_result(31 downto 16);
lower <= temp_result(15 downto 0);
wait on A, B, SROR; -- manually define triggers
end process;
end Behavioral;
--AB and SROR in sensitivity list instead of wait can use case statement instead
