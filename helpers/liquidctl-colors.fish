#!/usr/bin/env fish
liquidctl --serial 1305006473291217 set led1 color clear
liquidctl --serial 1305006473291217 set led2 color clear
liquidctl --serial 1805006373291A10 set led1 color clear
liquidctl --serial 1805006373291A10 set led2 color clear
liquidctl --serial 1305006473291217 set led1 color fixed $argv[1]
liquidctl --serial 1305006473291217 set led2 color fixed $argv[1]
liquidctl --serial 1805006373291A10 set led1 color fixed $argv[1]
liquidctl --serial 1805006373291A10 set led2 color fixed $argv[1]
