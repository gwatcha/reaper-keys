# jsfx

repo link: `https://github.com/molleweide/reaper-jsfx`

I have created an accompanying project called `reaper-jsfx`
where I started building on a library for managing midi devices.

The idea is that I am hooking into this jsfx with the function
`updateMidiPreProcessorByInputDevice` which allows for setting
up a custom vim-midi-controller for each device that one owns
so that one can access various midi functions easilly whilst
being recording or playing an instrument.

Also my idea is that if no midi instruments are found then
default to `vkb` mode or virtual_keyboard which would be 
access via vkb mode.
