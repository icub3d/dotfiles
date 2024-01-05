function bench
        echo 0 | sudo tee /proc/sys/kernel/nmi_watchdog >/dev/null
		command $argv
        echo 1 | sudo tee /proc/sys/kernel/nmi_watchdog >/dev/null
end
