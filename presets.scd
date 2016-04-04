/*
Using Ndef as a flexible architecture to use presets.
Fixing the midi mapping allow to move from one to another preset without remapping each time.
For that the arguments have to be shared between synths and the scaling of the values can be done inside the synth.
I suggest to use generic names like cc1, cc2...etc and remap them inside the synth with names that make more sense to the UGen's graph.
All the controllers come inside the synth on the midi range and get the actual values inside the synth, this allow to control different ranges with the same controller.
In the code below an example of setting 24 continuos controls, note in and pitch bend.
Program change can move between synths by changing the source of the Ndef.

*/

<<<<<<< HEAD
//This is the idea
=======
//This is the main tool
>>>>>>> 11eef924f1ed1e3a14a9bb5570c9c44c190a4715
/*
// use this for testing
~synth1={SinOsc.ar([440,660])};
~synth2={Saw.ar([440,660])};
~synth3={WhiteNoise.ar(0.1)!2};
~synth4={Silence.ar()};
<<<<<<< HEAD
=======
*/
(
Ndef(\synth).play;
Ndef(\synth).fadeTime=4;
)
>>>>>>> 11eef924f1ed1e3a14a9bb5570c9c44c190a4715
Ndef(\synth).pause;
Ndef(\synth).resume;
Ndef(\synth).clear;
Ndef(\synth).source=~synth1;
Ndef(\synth).source=~synth2;
Ndef(\synth).source=~synth3;
Ndef(\synth).source=~synth4;
Ndef(\synth).gui;
<<<<<<< HEAD
*/

Server.default.waitForBoot{

	s = Server.default;

(
		Ndef(\synth).play;
		Ndef(\synth).fadeTime=4;
);
	"Ndef synth created with fade time = 4".postln;

	s.sync;

// Start MIDI and Mapping
(
		MIDIClient.init;
		MIDIIn.connectAll;
);

	s.sync;

// Map to your controller I use 127cc to have access to any cc number default cc
	127.do{|i|currentEnvironment.put(("cc"++i).asSymbol,i)};
// print them out
	127.do{|i|currentEnvironment.at(("cc"++i).asSymbol).postln};

	s.sync;

//assign them to the synth
(
		127.do{|i|var env = currentEnvironment.at(("cc"++i).asSymbol);
			MIDIFunc.cc({|val,num,ch,src|Ndef(\synth).set(("cc"++i).asSymbol, val);
			//[num,val].postln;
			},env);
};
// assign note on and off messages include velocity
		MIDIFunc.noteOn({arg vel, note, ch, src;
			Ndef(\synth).set(\note, note, \tgate, 1, \vel, vel);
			//note.postln
		});

		MIDIFunc.noteOff({arg vel, note, ch, src;
			Ndef(\synth).set(\tgate, 0)});

// pitch bend
		MIDIFunc.bend({arg val, ch, src;
			//[val, ch, src].postln
			Ndef(\synth).set(\bend, val)});


		MIDIFunc.program({arg val, ch, src;
			//[val, ch, src].postln;
			Ndef(\synth).source = currentEnvironment.at(("synth"++val).asSymbol);
			["playing: " ++ "synth"++val].postln;
		});

);

	"MIDI running and mapping notes on/off, velocity, cc, bend and program changes".postln;

//Sources

~synth0={Silence.ar!2};

(
~synth1={arg note=60, vel= 1, tgate=1, bend=0, cc1=60, cc2=1, cc3=0, cc4=0, cc5=0, cc6=0, cc7=60, cc8=60, cc9=120, cc10=0, cc11=127, cc12=0, cc13, cc14, cc15, cc16=0.01, cc17=127, cc18=127, cc19=127, cc20=10, cc21=30, cc22=100, cc23=40, cc24, cc25, cc26, cc27, cc28, cc29, cc30, cc31, cc32, cc33, cc34, cc35, cc64, cc65, cc82=1, cc83=0, cc84=0, cc88=0, cc90=0, cc91=1, cc92=0;

	var output, env, velCtrl, gate=1, pos=0, oscillators, filters, fx;
	var oscillator1, oscillator2=1, carFreq=1, modFreq, waveform1, waveform2, amp1, amp2, amp3=0;
	var modulation, lfo=1, lfoFreq=1, lfoAmp=1, waveformLfo, lfoPitchAmnt=1, lfoFilterAmnt=0, lfoWaveAmnt=0;
	var octave1=1, octave2=1, bendFactor=0, suboscillator;
	var attack, decay, sustain, release, index, offset, ffreq, rq, saturation=1, morphing=0,keyTrack=0;
	var delay, feedback, wet, reverb, pitchShift, delays, fxAmp1,fxAmp2, fxAmp3;
    var modulator, carrier, filter1, filter2;
	var envFilter, attackFilter, decayFilter, sustainFilter, releaseFilter, envamountFilter=0;
	var envPitch, envLfoRate, envLfoAmp;


	velCtrl = vel.linlin(0, 127, 0, 0.8);
	amp1 = cc7.linlin(0, 127, 0, 1);
	amp2 = cc8.linlin(0, 127, 0, 1);
	amp3 = cc1.linlin(0, 127, 0, 1);
	octave1 = cc64.linlin(0, 127, 1, 4);
	octave2 = cc65.linlin(0, 127, 1, 4);
	bendFactor = bend.linlin(0, 16383, -1000, 1000) - 0.0610352;
	modulation = cc9.linlin(0, 127, 0, 1000);

	waveformLfo = cc92.linlin(0, 127, 0, 2).round;
	lfoPitchAmnt = cc90.linlin(0,127,0,1) > 0.6;
	lfoFilterAmnt = cc90.linlin(0,64,0,1) < 0.6;
	lfoWaveAmnt = (cc90 < 127) & (cc90 > 0);
	envPitch = cc10.linlin(0,127,0,1);
	envLfoRate = cc91.linlin(0,127,0,1) > 0.6;
	envLfoAmp = cc91.linlin(0,127,0,1) < 0.6;
	//carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = ((note.midicps*octave2)+bendFactor) + cc3.linlin(0, 127, 1, 1000);
	fxAmp1 = cc88.linlin(0,127,0,1) > 0.6;
	fxAmp2 = cc88.linlin(0,64,0,1) < 0.6;
	fxAmp3 = (cc88 < 127) & (cc88 > 0);

	index = cc10.linlin(0, 127, 0, 4*pi);
	//offset = cc4.linlin(0, 127, 1, 1000);
	saturation = cc82.linlin(0, 127, 1, 4);

	attack = cc16.linlin(0, 127, 1e-5, 2);
	decay = cc17.linlin(0, 127, 1e-5, 2);
	sustain = cc18.linlin(0, 127, 0, 1);
	release = cc19.linlin(0, 127, 1e-5, 10);

	attackFilter = cc20.linlin(0, 127, 0, 2);
	decayFilter = cc21.linlin(0, 127, 0, 2);
	sustainFilter = cc22.linlin(0, 127, 0, 1000);
	releaseFilter = cc23.linlin(0, 127, 0, 2);
	envamountFilter = cc13.linlin(0, 127, 0, 1);

	rq = cc12.linlin(0, 127, 0, 2);
	morphing = cc84.linlin(0, 127, 0, 1);

	delay = cc30.linlin(0,127,0.001,1);
	feedback = cc31.linlin(0,127,0,1.0);
	wet = cc29.linlin(0,127,-1,1);


    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), tgate, levelScale:velCtrl, doneAction:0);
	envFilter = EnvGen.ar(Env.adsr(attackFilter,decayFilter,1,releaseFilter), tgate, levelScale:sustainFilter,doneAction:0);

	lfoFreq = cc24.linexp(0,127,0.1,100) + (envFilter * envLfoRate);
	lfoAmp = cc26.linlin(0,127,0,1000) + (envFilter * envLfoAmp);

	lfo = SelectX.kr(waveformLfo, [
				LFDNoise0.kr(lfoFreq),
				//LFTri.kr(lfoFreq),
				//LFPar.kr(lfoFreq),
				LFPulse.kr(lfoFreq),
				LFSaw.kr(lfoFreq),
	] * lfoAmp);


	waveform1 = cc4.linlin(0,127,0,3) + (lfo.range(0,3) * lfoWaveAmnt);
	waveform2 = cc5.linlin(0,127,0,3);

	oscillator2 = SelectX.ar(waveform2, [
		SinOsc.ar(modFreq),
		LFTri.ar(modFreq),
		SawDPW.ar(modFreq),
		PulseDPW.ar(modFreq)] * 0.3);

	carFreq = ((note.midicps*octave1)+bendFactor) + cc2.linlin(0, 127, 1, 1000) +
	(oscillator2*modulation) + (lfo * lfoPitchAmnt) + (envFilter * envPitch);
	keyTrack = cc83.linlin(0,127,0,2);
	ffreq = cc11.midicps+(note.midicps*keyTrack) + (lfo * lfoFilterAmnt);


	oscillator1 = SelectX.ar(waveform1, [
		SinOsc.ar(carFreq),
		LFTri.ar(carFreq),
		SawDPW.ar(carFreq),
		PulseDPW.ar(carFreq)] * 0.3);


	suboscillator = PulseDPW.ar(note.midicps*0.25+bendFactor,0.5,0.3);


	//oscillators = (oscillator1 * amp1) + (oscillator2 * amp2) + (suboscillator * amp3);
	oscillators = Mix([oscillator1*amp1, oscillator2*amp2, suboscillator*amp3]);
	//output = BMoog.ar(output, ffreq+((envFilter.max(20).min(20000))*envamountFilter), rq, 0.5);
	//output = RLPF.ar(output, ffreq+((envFilter.max(20).min(20000))*envamountFilter), 1-rq);
	filters = DFM1.ar(oscillators, ffreq+((envFilter.max(20).min(20000))*envamountFilter), rq, saturation, morphing);

	reverb = GVerb.ar(filters,100,delay,0.5,0.5,15,feedback,0.7,0.5,300,fxAmp1);
	//delays = SwitchDelay.ar(filters,1,1,delay,feedback,2,1,filters);
	delays = CombC.ar(filters,2,delay,feedback,fxAmp2,filters);
	pitchShift = PitchShift.ar(filters,0.2,delay*4,feedback,fxAmp3);
	//output = filters;
	fx = Mix([reverb, delays, pitchShift]);
	output = XFade2.ar (filters, fx, wet);

	output*env
	//Pan2.ar(output,pos,env*vol);
};
/*
		Ndef(\synth).source=~synth1;
*/
	);




(
~synth2={arg note=60, vol= 1, tgate=1, cc1=60, cc2=1, cc3=0, cc4=0, cc5=0, cc6=120, cc7=127, cc8=60, cc9=120, cc10=0, cc11=0, cc12=127, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30, cc31, cc32, cc33, cc34, cc35;
=======
(
MIDIClient.init;
MIDIIn.connectAll;
);
// Map to your controller
(
~cc1 = 4;
~cc2 = 9;
~cc3 = 10;
~cc4 = 1;
~cc5 = 16;
~cc6 = 17;
~cc7 = 18;
~cc8 = 19;
~cc9 = 11;
~cc10 = 12;

~cc11 = 13;
~cc12 = 7;
~cc13 = 30;
~cc14 = 31;

~cc15 = 29;
~cc16 = 4;
// ~cc17 = 22;
// ~cc18 = 23;
//
// ~cc19 = 24;
// ~cc20 = 26;
// ~cc21 = 92;
//
// ~cc22 = 29;
// ~cc23 = 30;
// ~cc24 = 31;

);

//default cc
(
~cc1 = 1;
~cc2 = 2;
~cc3 = 3;
~cc4 = 4;
~cc5 = 5;
~cc6 = 6;
~cc7 = 7;
~cc8 = 8;
~cc9 = 9;
~cc10 = 10;

~cc11 = 11;
~cc12 = 12;
~cc13 = 13;
~cc14 = 14;

~cc15 = 15;
~cc16 = 16;
~cc17 = 17;
~cc18 = 18;
~cc19 = 19;
~cc20 = 20;
~cc21 = 21;
~cc22 = 22;
~cc23 = 23;
~cc24 = 24;

);

// print them out
25.do{|i|currentEnvironment.at(("cc"++i).asSymbol).postln};

//assign them to the synth
(
25.do{|i|var env = currentEnvironment.at(("cc"++i).asSymbol);
	MIDIFunc.cc({|val,num,ch,src|Ndef(\synth).set(("cc"++i).asSymbol, val);
		//[num,val].postln;
		},env);
};
// assign note on messages
MIDIFunc.noteOn({arg vel, note, ch, src;Ndef(\synth).set(\note, note, \tgate, 1);
	//note.postln
	});
MIDIFunc.noteOff({arg vel, note, ch, src;Ndef(\synth).set(\tgate, 0)});

);

//Sources
(
~synth1={arg note=60, vol= 1, tgate=1, cc1=60, cc2=1, cc3=0, cc4=0, cc5=0, cc6=120, cc7=127, cc8=60, cc9=120, cc10=0, cc11=0, cc12=127, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30;

	var carFreq, modFreq, attack, decay, sustain, release, index, offset, ffreq, rq, morphing, amp;
	var delay, feedback, wet;
    var modulator, carrier, filter1, filter2, output, env, gate=1, pos=0;

	carFreq = note.midicps;
	//carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = cc2.linlin(0, 127, 0.1, 1000);
	//gate = cc1.linlin(0, 127, 20, 20000);

	index = cc3.linlin(0, 127, 0, 4*pi);
	offset = cc4.linlin(0, 127, 1, 1000);

	attack = cc5.linlin(0, 127, 0, 2);
	decay = cc6.linlin(0, 127, 0, 2);
	sustain = cc7.linlin(0, 127, 0, 1);
	release = cc8.linlin(0, 127, 0, 2);


	ffreq = cc9.midicps;
	rq = cc10.linlin(0, 127, 0, 1);
	morphing = cc11.linlin(0, 127, -1, 1);
	amp = cc12.linlin(0, 127, 0, 1);

	delay = cc13.linlin(0,127,0.001,2);
	feedback = cc14.linlin(0,127,0,1.0);
	wet = cc15.linlin(0,127,-1,1);

    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), tgate, doneAction:0);
//	modulator = SinOsc.kr(modFreq,0,index,offset);
//  carrier = SinOsc.ar(carFreq+modulator);
	carrier = PMOsc.ar(carFreq, modFreq, index);
	carrier = XFade2.ar (carrier, PitchShift.ar(carrier,0.1,1,delay,feedback), wet);
	filter1 = DFM1.ar(carrier, ffreq, rq);
    filter2 = BMoog.ar(carrier, ffreq, rq, offset, 0.5);
	//var filter1 = LPF.ar(carrier, ffreq, rq);
	//var filter2 = HPF.ar(carrier, ffreq, rq);
	output = XFade2.ar (filter1, filter2, morphing);

	Pan2.ar(output,pos,env*amp*vol);

}
);

Ndef(\synth).source=~synth1;

(
~synth2={arg note=60, vol= 1, tgate=1, cc1=60, cc2=1, cc3=0, cc4=0, cc5=0, cc6=0, cc7=127, cc8=60, cc9=120, cc10=0, cc11=0, cc12=127, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30;
>>>>>>> 11eef924f1ed1e3a14a9bb5570c9c44c190a4715

	var carFreq, modFreq, attack, decay, sustain, release, index, offset, ffreq, rq, morphing, amp;
	var delay, feedback, wet;
    var modulator, carrier, filter1, filter2, output, env, gate=1, pos=0;
<<<<<<< HEAD

	carFreq = note.midicps;
	//carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = cc9.linlin(0, 127, 0.1, 1000);
	//gate = cc1.linlin(0, 127, 20, 20000);

	index = cc10.linlin(0, 127, 0, 4*pi);
	offset = cc4.linlin(0, 127, 1, 1000);

	attack = cc16.linlin(0, 127, 0, 2);
	decay = cc17.linlin(0, 127, 0, 2);
	sustain = cc18.linlin(0, 127, 0, 1);
	release = cc19.linlin(0, 127, 0, 2);


	ffreq = cc11.midicps;
	rq = cc12.linlin(0, 127, 0, 1);
	morphing = cc13.linlin(0, 127, -1, 1);
	amp = cc7.linlin(0, 127, 0, 1);

	delay = cc30.linlin(0,127,0.001,2);
	feedback = cc31.linlin(0,127,0,1.0);
	wet = cc29.linlin(0,127,-1,1);

    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), tgate, doneAction:0);
//	modulator = SinOsc.kr(modFreq,0,index,offset);
//  carrier = SinOsc.ar(carFreq+modulator);
	carrier = PMOsc.ar(carFreq, modFreq, index);
	carrier = XFade2.ar (carrier, PitchShift.ar(carrier,0.1,1,delay,feedback), wet);
	filter1 = DFM1.ar(carrier, ffreq, rq);
    filter2 = BMoog.ar(carrier, ffreq, rq, offset, 0.5);
	//var filter1 = LPF.ar(carrier, ffreq, rq);
	//var filter2 = HPF.ar(carrier, ffreq, rq);
	output = XFade2.ar (filter1, filter2, morphing);

	Pan2.ar(output,pos,env*amp*vol);

}
);
/*
Ndef(\synth).source=~synth2;
*/
=======
	var envFilter, attackFilter, decayFilter, sustainFilter, releaseFilter, saturation=1, envamountFilter=0;

	carFreq = note.midicps;
	//carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = cc2.linlin(0, 127, 0.1, 1000);
	//gate = cc1.linlin(0, 127, 20, 20000);

	index = cc3.linlin(0, 127, 0, 4*pi);
	//offset = cc4.linlin(0, 127, 1, 1000);
	saturation = cc4.linlin(0, 127, 1, 1000);

	attack = cc5.linlin(0, 127, 0, 2);
	decay = cc6.linlin(0, 127, 0, 2);
	sustain = cc7.linlin(0, 127, 0, 1);
	release = cc8.linlin(0, 127, 0, 2);

	attackFilter = cc15.linlin(0, 127, 0, 2);
	decayFilter = cc16.linlin(0, 127, 0, 2);
	sustainFilter = cc17.linlin(0, 127, 0, 100);
	releaseFilter = cc18.linlin(0, 127, 0, 2);
	envamountFilter = cc19.linlin(0, 127, 0, 1);

	ffreq = cc9.midicps;
	rq = cc10.linlin(0, 127, 0, 1);
	morphing = cc11.linlin(0, 127, -1, 1);
	amp = cc12.linlin(0, 127, 0, 1);

	delay = cc13.linlin(0,127,0.001,2);
	feedback = cc14.linlin(0,127,0,1.0);
	wet = cc20.linlin(0,127,-1,1);

    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), tgate, doneAction:0);
	envFilter = EnvGen.ar(Env.adsr(attackFilter,decayFilter,1,releaseFilter), tgate, doneAction:0)*sustainFilter;
//	modulator = SinOsc.kr(modFreq,0,index,offset);
//  carrier = SinOsc.ar(carFreq+modulator);
	//carrier = PMOsc.ar(carFreq, modFreq, index);
	//carrier = XFade2.ar (carrier, PitchShift.ar(carrier,0.1,1,delay,feedback), wet);
	//filter1 = DFM1.ar(carrier, ffreq, rq);
    //filter2 = BMoog.ar(carrier, ffreq, rq, offset, 0.5);
	//var filter1 = LPF.ar(carrier, ffreq, rq);
	//var filter2 = HPF.ar(carrier, ffreq, rq);
	//output = XFade2.ar (filter1, filter2, morphing);

	//output = Pulse.ar(carFreq,[rq,rq+0.1]);
	output = SawDPW.ar(carFreq,[index,index+0.1]);
	output = BMoog.ar(output, ffreq*(envFilter*envamountFilter+0.01), rq, 0.5);
	//Pan2.ar(output,pos,env*amp*vol);

	output*env*amp*vol

}
);

Ndef(\synth).source=~synth2;

>>>>>>> 11eef924f1ed1e3a14a9bb5570c9c44c190a4715
(
~synth3={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, index=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    var sin = Pulse.kr(modFreq,0.5,index,offset);
    var osc= LFTri.ar(carFreq+sin);
    var filter1 = DFM1.ar(osc, ffreq, rq);
    var filter2 = BMoog.ar(osc, ffreq, rq, 2, 0.5);
	//var filter1 = LPF.ar(osc, ffreq, rq);
	//var filter2 = HPF.ar(osc, ffreq, rq);
	var output = XFade2.ar (filter1, filter2, morphing,);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	output*env*0.5*amp;}
);


(
~synth4={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, index=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    //var sin = Pulse.kr(modFreq,0.5,index,offset);
	var sin = Dseq([60,63,62,67,68,67,72].midicps,inf);
	var arp = Demand.kr(Impulse.kr(modFreq),0,sin);
    var osc= LFTri.ar(carFreq+arp);
    var filter1 = DFM1.ar(osc, ffreq, rq);
    var filter2 = BMoog.ar(osc, ffreq, rq, 2, 0.5);
	//var filter1 = LPF.ar(osc, ffreq, rq);
	//var filter2 = HPF.ar(osc, ffreq, rq);
	var output = XFade2.ar (filter1, filter2, morphing,);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	output*env*0.5*amp;}
);

<<<<<<< HEAD
	"ready to play, change presets with program change".postln;
}
=======


>>>>>>> 11eef924f1ed1e3a14a9bb5570c9c44c190a4715
/*
MIDIFunc.cc({|val,num,ch,src|~cc1Pot = val; Ndef(\synth).set(\cc1, val)},~cc1);
MIDIFunc.cc({|val,num,ch,src|~cc2Pot = val; Ndef(\synth).set(\cc2, val)},~cc2);
MIDIFunc.cc({|val,num,ch,src|~cc3Pot = val; Ndef(\synth).set(\cc3, val)},~cc3);
MIDIFunc.cc({|val,num,ch,src|~cc4Pot = val; Ndef(\synth).set(\cc4, val)},~cc4);
MIDIFunc.cc({|val,num,ch,src|~cc5Pot = val; Ndef(\synth).set(\cc5, val)},~cc5);
MIDIFunc.cc({|val,num,ch,src|~cc6Pot = val; Ndef(\synth).set(\cc6, val)},~cc6);
MIDIFunc.cc({|val,num,ch,src|~cc7Pot = val; Ndef(\synth).set(\cc7, val)},~cc7);
MIDIFunc.cc({|val,num,ch,src|~cc8Pot = val; Ndef(\synth).set(\cc8, val)},~cc8);
MIDIFunc.cc({|val,num,ch,src|~cc9Pot = val; Ndef(\synth).set(\cc9, val)},~cc9);
MIDIFunc.cc({|val,num,ch,src|~cc10Pot = val; Ndef(\synth).set(\cc10, val)},~cc10);
*/

<<<<<<< HEAD
=======

>>>>>>> 11eef924f1ed1e3a14a9bb5570c9c44c190a4715
