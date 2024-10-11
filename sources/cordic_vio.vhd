library IEEE;
use IEEE.std_logic_1164.all;

entity cordic_VIO is
    generic(
        BITS_VIO: natural := 18
    );
    port(
        clk_i: in std_logic
    );
end entity;

architecture cordic_VIO_arq of cordic_VIO is
  component cordic_iterativa is
    generic(
        BITS: natural := 18
    );
    port( 
        clk   : in std_logic;
        rst   : in std_logic_vector(0 downto 0);
        start : in std_logic_vector(0 downto 0);

        xi : in std_logic_vector(BITS-2 downto 0);
        yi : in std_logic_vector(BITS-2 downto 0);
        zi : in std_logic_vector(BITS-1 downto 0);

        xo : out std_logic_vector(BITS-2 downto 0);
        yo : out std_logic_vector(BITS-2 downto 0);
        zo : out std_logic_vector(BITS-1 downto 0)
    );
  end component;
  
  component vio_0
    PORT (
      clk : IN STD_LOGIC;
      probe_in0 : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
      probe_in1 : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
      probe_in2 : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
      probe_out0 : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
      probe_out1 : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
      probe_out2 : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
      probe_out3 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe_out4 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
  end component;

  signal rst_vio   : std_logic_vector(0 downto 0);
  signal start_vio : std_logic_vector(0 downto 0);

  signal input_x_vio : std_logic_vector(BITS_VIO-2 downto 0);
  signal input_y_vio : std_logic_vector(BITS_VIO-2 downto 0);
  signal input_z_vio : std_logic_vector(BITS_VIO-1 downto 0);

  signal output_x_vio : std_logic_vector(BITS_VIO-2 downto 0);
  signal output_y_vio : std_logic_vector(BITS_VIO-2 downto 0);
  signal output_z_vio : std_logic_vector(BITS_VIO-1 downto 0);

begin

  cordic_iterativa_inst: cordic_iterativa
  generic map(
      BITS => BITS_VIO
  )
  port map(
      clk   => clk_i,
      rst   => rst_vio,
      start => start_vio,
      xi    => output_x_vio,
      yi    => output_y_vio,
      zi    => output_z_vio,
      xo    => input_x_vio,
      yo    => input_y_vio,
      zo    => input_z_vio
  );
  
  vio_inst : vio_0
    PORT MAP (
      clk => clk_i,
      probe_in0 => input_x_vio,
      probe_in1 => input_y_vio,
      probe_in2 => input_z_vio,
      probe_out0 => output_x_vio,
      probe_out1 => output_y_vio,
      probe_out2 => output_z_vio,
      probe_out3 => rst_vio,
      probe_out4 => start_vio
    );
end architecture;