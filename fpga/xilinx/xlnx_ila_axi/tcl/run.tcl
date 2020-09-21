set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_ila_axi

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

    # AXI:
    #
    # AR Channel (Read Address):
    # 00: ar_id      (4)
    # 01: ar_addr   (64)
    # 02: ar_len     (8)
    # 03: ar_size    (3)
    # 04: ar_burst   (2)
    # 05: ar_lock    (1)
    # 06: ar_cache   (4)
    # 07: ar_prot    (3)
    # 08: ar_qos     (4)
    # 09: ar_region  (4)
    # 10: ar_valid   (1)
    # 11: ar_ready   (1)
    #
    # R Channel (Read Data):
    # 12: r_id       (4)
    # 13: r_data    (64)
    # 14: r_resp     (2)
    # 15: r_last     (1)
    # 16: r_valid    (1)
    # 17: r_ready    (1)

create_ip -name ila -vendor xilinx.com -library ip -module_name $ipName
set_property -dict [list  CONFIG.C_NUM_OF_PROBES {28} \
                          CONFIG.C_PROBE0_WIDTH {4} \
                          CONFIG.C_PROBE1_WIDTH {64} \
                          CONFIG.C_PROBE2_WIDTH {8} \
                          CONFIG.C_PROBE3_WIDTH {3} \
                          CONFIG.C_PROBE4_WIDTH {2} \
                          CONFIG.C_PROBE5_WIDTH {1} \
                          CONFIG.C_PROBE6_WIDTH {4} \
                          CONFIG.C_PROBE7_WIDTH {3} \
                          CONFIG.C_PROBE8_WIDTH {4} \
                          CONFIG.C_PROBE9_WIDTH {4} \
                          CONFIG.C_PROBE10_WIDTH {1} \
                          CONFIG.C_PROBE11_WIDTH {1} \
                          CONFIG.C_PROBE12_WIDTH {4} \
                          CONFIG.C_PROBE13_WIDTH {64} \
                          CONFIG.C_PROBE14_WIDTH {2} \
                          CONFIG.C_PROBE15_WIDTH {1} \
                          CONFIG.C_PROBE16_WIDTH {1} \
                          CONFIG.C_PROBE17_WIDTH {1} \
                          CONFIG.C_PROBE18_WIDTH {1} \
                          CONFIG.C_PROBE19_WIDTH {1} \
                          CONFIG.C_PROBE20_WIDTH {1} \
                          CONFIG.C_PROBE21_WIDTH {1} \
                          CONFIG.C_PROBE22_WIDTH {1} \
                          CONFIG.C_PROBE23_WIDTH {32} \
                          CONFIG.C_PROBE24_WIDTH {32} \
                          CONFIG.C_PROBE25_WIDTH {32} \
                          CONFIG.C_PROBE26_WIDTH {32} \
                          CONFIG.C_PROBE27_WIDTH {32} \
                          CONFIG.C_DATA_DEPTH {16384}
                        #   CONFIG.C_INPUT_PIPE_STAGES {1} 
                    ] [get_ips $ipName]


generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1