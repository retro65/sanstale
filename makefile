run:
	love . debug

love:
	mkdir lovetmp
	cp *.lua res lib game ./lovetmp -r
	cd lovetmp && zip -9 -q -r ../builds/sanstale.love .
	rm -rf ./lovetmp

win: love
	cat love-0.10.0-win32/love.exe builds/sanstale.love > builds/sanstale.exe
	cp love-0.10.0-win32/*.dll builds/
	cd builds && zip -9 -q -r sanstale-win.zip sanstale.exe *.dll
	rm builds/*.dll builds/sanstale.exe

mac: love #todo

clean:
	rm builds/* -i
	
