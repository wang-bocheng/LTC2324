#Generated by Fabric Compiler ( version 2021.1-SP7.1 <build 90533> ) at Fri Sep 16 17:07:31 2022

add_design "F:/444/code/FPGA/acoustic_camera/LTC2324_cmos/source/LTC2324_cmos.v"
add_design "F:/444/code/FPGA/acoustic_camera/LTC2324_cmos/source/deserializer.v"
add_design "F:/444/code/FPGA/acoustic_camera/LTC2324_cmos/source/pluse_generate.v"
add_design "F:/444/code/FPGA/acoustic_camera/LTC2324_cmos/source/fenp.v"
add_design F:/444/code/FPGA/acoustic_camera/LTC2324_cmos/ipcore/pll/pll.idf
set_arch -family Logos -device PGL50H -speedgrade -6 -package FBG484
compile -top_module LTC2324_cmos