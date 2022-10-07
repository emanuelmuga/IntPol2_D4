package require ::quartus::project
package require fileutil


set folderName "../IntPol2_D4_IQ/mods"

foreach file [fileutil::findByPattern $folderName *.v] {
    puts $file
    set_global_assignment -name VERILOG_FILE $file
}

foreach file [fileutil::findByPattern $folderName *.sv] {
    puts $file
    set_global_assignment -name SYSTEMVERILOG_FILE $file
}