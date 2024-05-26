prepare:
	apt install wget libmp3lame0 libxml2 curl xdotool
	mkdir reaper; mkdir reaper-config; touch reaper-config/cfg.ini
	
	wget -qO- http://reaper.fm/files/7.x/reaper715_linux_x86_64.tar.xz | tar xfJ -
	mv -t reaper/ reaper_linux_x86_64/REAPER/{InstallData,Plugins,Resources,rea*,libSwell.so}
	export PATH=$(PATH):./reaper
	
	timeout 2 reaper -cfgfile reaper-config/cfg.ini || true # copies from InstallData to reaper-config
	
	rm -fr reaper_linux_x86_64 reaper/{InstallData,Plugins/reaper_{python.so,video.so}} \
		reaper-config/Data/{toolbar_icons,track_icons,amp_models,joystick_midi,seqbaby_data} \
		reaper-config/{ColorThemes,Scripts/Cockos/D*,OSC,KeyMaps,MIDINoteNames,MouseMaps,LangPack,Cursors}

test:
	test='create-track'
	session=$(test).rks
	expected=$(test).rpp
	out=$(test)-out.rpp
	pid=$(reaper -saveas $out -cfgfile reaper-config/cfg.ini -new -nosplash 1>stdout 2>stderr &)
	
	while read p; do
		xdotool type "$p"
	done <$session
	
	xdotool type " ps"
	kill $pid
	diff $expected $out
