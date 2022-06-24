function liquid
	liquidctl initialize all
	liquidctl --serial 1805006373291A10 set fan1 speed 20 800 30 900 40 1000 50 1500 60 2000 --temperature-sensor 3
	liquidctl --serial 1805006373291A10 set fan2 speed 20 800 30 900 40 1000 50 1500 60 2000 --temperature-sensor 3
	liquidctl --serial 1805006373291A10 set led1 color fixed 00ff00
	liquidctl --serial 1805006373291A10 set led2 color fixed 00ff00
	liquidctl --serial 1305006473291217 set fan1 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan2 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan3 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan4 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan5 speed 20 800 40 900 50 1000 60 1500 70 2000 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set fan6 speed 20 800 30 1500 40 2000 50 2500 55 3500 60 4800 --temperature-sensor 1
	liquidctl --serial 1305006473291217 set led1 color fixed 00ff00
	liquidctl --serial 1305006473291217 set led2 color fixed 00ff00
end
