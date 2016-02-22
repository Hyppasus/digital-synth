/*#########################################################################################################*/
/*#########################################################################################################*/
// For this synth you will nee to download the wavetables AKWF from
// "http://www.adventurekid.se/akrt/waveforms/adventure-kid-waveforms/"
// I suggest to make a selection since there are more than 4000 tables
// This patch also uses the two objects from the Quarks (use QuarksGui.new to fetch them):
// Voicer and VoicerMIDISocket
// you need a midi keyboard with 8 cc

(
Server.default.waitForBoot{

	s = Server.default;
	~tables=[]; // an empty Array to address the wavetables loaded in Buffers
	//define midi continuos controllers, use your own keyboard
	~bufoffsetCC = 2;
	~scaleCC = 4;
	~volCC = 27;
	~freqModCC = 3;
	~buffOffsetModCC = 5;
	~volModCC = 24;
	~mulModCC = 9;
	~addModCC = 10;


	//change the path
(
	"/Users/you/Sounds/AKWF/*/*.wav".pathMatch.collect({|paths, i|
		~tables=~tables.add(
			Buffer.readChannel(
				s,paths, startFrame:0, numFrames:512, bufnum:i, channels:0,
				action:{|b|	b.loadToFloatArray(
					action:{|a|a.value.as(Signal).asWavetable;
						[a.bufnum, ": done"].postln;
							});
						});
			)};
	)
);

	s.sync;

(
~loadSynth={
(
SynthDef("vosc",{ arg outbus=0, bufoffset=0, scale=0, freq=440, attack=0.01, decay=0.1, sustain=1, release=1, gate=1, vol=1, phase=0, bufoffsetMod=0, freqMod=1, volMod=0, mul=1, add=0;
	var env, sig, amp, mod;
	amp = Latch.kr(gate, gate) * 0.5 + 0.5;
	env = EnvGen.ar(Env.adsr(attack,decay,sustain,release),gate,doneAction:2);
	mod = VOsc.ar(bufoffsetMod, freqMod, phase, mul, add)*volMod;
	sig = VOsc.ar(bufoffset+scale, freq+mod, phase, amp);
	sig = sig * env * vol;
    Out.ar(outbus,sig);
}).add
);
	"synth loaded".postln;
	0.1.wait;

	~voicer = Voicer(8, "vosc");
	~keyboard = VoicerMIDISocket([\all, \omni], ~voicer);

	"Voicer loaded".postln;
	0.1.wait;

	(
		~keyboard.addControl(~bufoffsetCC, \bufoffset, 0, [0,10.0, \linear] );
		~keyboard.addControl(~scaleCC, \scale, 0, [0,~tables.size,\linear] );
		~keyboard.addControl(~volCC, \vol, 0, [0,1.0,\linear]);
		~keyboard.addControl(~freqModCC, \freqMod, 0, [0.01,1000.0,\exponential]);
		~keyboard.addControl(~buffOffsetModCC, \bufoffsetMod, 0, [0,~tables.size, \linear] );
		~keyboard.addControl(~volModCC, \volMod, 0, [0,1.0,\linear]);
		~keyboard.addControl(~mulModCC, \mul, 0, [1,1000.0,\exponential]);
		~keyboard.addControl(~addModCC, \add, 0, [0,1000.0,\linear]);
);
	"midi ready".postln;
}
);
	8.wait; // this time can be adjusted acording to the amount of tables
	~loadSynth.fork;
	}
);