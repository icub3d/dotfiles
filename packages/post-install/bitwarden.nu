let bin_dir = ($nu.home-dir | path join "bin")
let bw_bin = ($bin_dir | path join "bw")
if not ($bw_bin | path exists) {
    mkdir $bin_dir
    http get "https://vault.bitwarden.com/download/?app=cli&platform=linux" | save -f bw.zip
    unzip -o bw.zip -d $bin_dir out> /dev/null
    chmod +x $bw_bin
    rm bw.zip
}
