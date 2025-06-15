library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity top_level is
port (
DMD: inout std_logic_vector(15 downto 0);
R: inout std_logic_vector(15 downto 0);
Clk : in std_logic;
Load : in std_logic;
shift_code : in std_logic_vector(7 downto 0);
ar_lo : in std_logic;
hi_lo : in std_logic;
MuxSel : in std_logic_vector(3 downto 0);
num : in std_logic_vector(15 downto 0);
--OutFinal : out std_logic_vector(3 downto 0)
segment_0 : out std_logic_vector(6 downto 0); -- display orp_lower(11 downto 8)
segment_1 : out std_logic_vector(6 downto 0); -- display orp_lower(15 downto 12)
segment_2 : out std_logic_vector(6 downto 0); -- display orp_upper(3 downto 0)
segment_3 : out std_logic_vector(6 downto 0); -- display orp_upper(7 downto 4)
segment_4 : out std_logic_vector(6 downto 0); -- display orp_upper(11 downto 8)
segment_5 : out std_logic_vector(6 downto 0); -- display orp_upper(15 downto 12)
LEDs : out std_logic_vector(7 downto 0) -- display orp_lower(7 downto 0)
--other input for nonhardcode
--enable_bit: in std_logic;
--select_orp: in std_logic
);
end top_level;
architecture Structural of top_level is
-- Signals
signal SI_out : std_logic_vector(15 downto 0);
signal mux1_out : std_logic_vector(15 downto 0);
signal mux2_out : std_logic_vector(15 downto 0);
signal mux3_out : std_logic_vector(15 downto 0);
signal mux4_out : std_logic_vector(15 downto 0);
signal shifter_out : std_logic_vector(31 downto 0);
signal orp_upper: std_logic_vector(15 downto 0);
signal orp_lower: std_logic_vector(15 downto 0);
signal sr1_out:std_logic_vector(15 downto 0);
signal sr0_out:std_logic_vector(15 downto 0);
signal tri1_out:std_logic_vector(15 downto 0);
signal tri2_out:std_logic_vector(15 downto 0);
signal tri3_out:std_logic_vector(15 downto 0);
--hardcoded signals DORMANT when in model sim but active for quartus
signal mux_1_sel : std_logic := '0';
signal mux_2_sel : std_logic := '0';
signal mux_3_sel : std_logic := '0';
signal mux_4_sel : std_logic := '0';
--signal input_code : std_logic_vector(7 downto 0) := "11111011"; -- negative 5
signal user_num: std_logic_vector(15 downto 0) := "1011011010100011";
signal enable_bit: std_logic := '0';
signal enable_bit2: std_logic := '0';
signal select_orp: std_logic := '1';
signal combined_output : std_logic_vector(31 downto 0);
-- Component declarations
component reg_16
port(Inp : in std_logic_vector(15 downto 0);
Load, Clk : in std_logic;
Outp : out std_logic_vector(15 downto 0));
end component;
component or_pass32
port(A : in std_logic_vector(31 downto 0);
B: in std_logic_vector(31 downto 0);
SROR: in std_logic;
upper: out std_logic_vector(15 downto 0);
lower: out std_logic_vector(15 downto 0));
end component;
component mux_2_1
port (Sel : in std_logic;
A, B : in std_logic_vector(15 downto 0);
X : out std_logic_vector(15 downto 0));
end component;
component shift_array
port(num : in std_logic_vector(15 downto 0);
code : in std_logic_vector(7 downto 0);
X : in std_logic;
hi_lo : in std_logic;
result : out std_logic_vector(31 downto 0));
end component;
component tristate_buffer16 is
port( input: in std_logic_vector(15 downto 0);
enable: in std_logic;
output: out std_logic_vector(15 downto 0));
end component;
component Display
port (
Input : in std_logic_vector(3 downto 0);
segmentSeven : out std_logic_vector(6 downto 0)
);
end component;
begin
--THIS ISNT USED IN THE SIMULATION, INPUTS FROM THE USER ARE USED THESE
SIGNALS WERE JUST FOR BOARD PURPOSES
process
begin
select_orp <= '1';
mux_1_sel <= '0';
mux_2_sel <= '0';
mux_3_sel <= '0';
mux_4_sel <= '0';
enable_bit <= '0'; -- or '0', depending on your goal
wait;
end process;
--begin
-- first 16-bit register
SI_Reg: reg_16 port map(Inp => num, Load => Load, Clk => Clk, Outp => SI_out);
-- 2:1 mux
mux_1: mux_2_1 port map(Sel => MuxSel(0), A => SI_out, B => R, X => mux1_out);
-- Shift array
=> shifter_out);
-- 32-bit register
combined_output <= sr1_out & sr0_out;
shifter: shift_array port map(num => mux1_out, code => shift_code, X => ar_lo, hi_lo => hi_lo, result
or_pass: or_pass32 port map(A => combined_output, B => shifter_out, SROR => select_orp, upper =>
orp_upper, lower => orp_lower);
--upper output mux
mux_2: mux_2_1 port map(Sel => MuxSel(1), A => orp_upper, B => DMD, X => mux2_out);
sr1: reg_16 port map (Inp => mux2_out, Load => Load, Clk => Clk, Outp => sr1_out);
--lower output
mux_3: mux_2_1 port map(Sel => MuxSel(2), A=>orp_lower, B => DMD, X => mux3_out);
sr0: reg_16 port map (Inp => mux3_out, Load => Load, Clk => Clk, Outp => sr0_out);
--tri states
tri_1: tristate_buffer16 port map(input => sr1_out, enable => enable_bit, output => R);
tri_2: tristate_buffer16 port map(input => sr0_out, enable => enable_bit2, output => R);
--last mux
mux_4: mux_2_1 port map(Sel => MuxSel(3), A=> orp_upper, B=> orp_lower, X=> mux4_out);
tri3: tristate_buffer16 port map(input => mux4_out, enable => enable_bit, output =>DMD);
--connect some of upper reg to 8 leds, connect rest of upper reg ad all of lower reg is to 7 segment display
disp0: Display port map(Input => orp_lower(11 downto 8), segmentSeven => segment_0);
disp1: Display port map(Input => orp_lower(15 downto 12), segmentSeven => segment_1);
disp2: Display port map(Input => orp_upper(3 downto 0), segmentSeven => segment_2);
disp3: Display port map(Input => orp_upper(7 downto 4), segmentSeven => segment_3);
disp4: Display port map(Input => orp_upper(11 downto 8), segmentSeven => segment_4);
disp5: Display port map(Input => orp_upper(15 downto 12), segmentSeven => segment_5);
LEDs <= orp_lower(7 downto 0);
end Structural;
