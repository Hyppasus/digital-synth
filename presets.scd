/*
Using Ndef as a flexible architecture to use presets.
Fixing the midi mapping allow to move from one to another preset without remapping each time.
For that the arguments have to be shared between synths and the scaling of the values can be done inside the synth.
I suggest to use generic names like cc1, cc2...etc and remap them inside the synth with names that make more sense to the UGen's graph.
In the code below an example of setting 24 continuos controls, note in and pitch bend.
Program change can move between synths by changing the source of the Ndef.

*/

//This is the main tool

a={SinOsc.ar(666)!2};
b={Saw.ar(666)!2};
c={WhiteNoise.ar(0.1)!2};

Ndef(\synth).play;
Ndef(\synth).fadeTime=4;
Ndef(\synth).pause;
Ndef(\synth).resume;
Ndef(\synth).clear;
Ndef(\synth).source=~synth1;
Ndef(\synth).source=~synth2;
Ndef(\synth).source=~synth3;
Ndef(\synth).source=~synth4;


// Map to your controller
(
~cc1 = 2;
~cc2 = 4;
~cc3 = 7;
~cc4 = 3;
~cc5 = 5;
~cc6 = 8;

~cc7 = 1;

~cc8 = 11;
~cc9 = 12;
~cc10 = 13;

~cc11 = 16;
~cc12 = 17;
~cc13 = 18;
~cc14 = 19;

~cc15 = 20;
~cc16 = 21;
~cc17 = 22;
~cc18 = 23;

~cc19 = 24;
~cc20 = 26;
~cc21 = 92;

~cc22 = 29;
~cc23 = 30;
~cc24 = 31;

);

// print them out
25.do{|i|currentEnvironment.at(("cc"++i).asSymbol).postln};

//assign them to the synth
(
25.do{|i|var env = currentEnvironment.at(("cc"++i).asSymbol);
	MIDIFunc.cc({|val,num,ch,src|Ndef(\synth).set(\cc10, val)},env);
};
);


//Sources
(
~synth1={arg cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8, cc9, cc10, cc11, cc12, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30;

	var carFreq= 30, modFreq=40, gate=1, attack=1, decay=1, sustain=120, release=4, depth=10, offset=10, ffreq = 120, rq = 0, morphing = 0, amp=127;
    var sin, osc, filter1, filter2, output, env;

	carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = cc2.linlin(0, 127, 20, 20000);
	//gate = cc1.linlin(0, 127, 20, 20000);
	attack = cc3.linlin(0, 127, 0, 2);
	decay = cc4.linlin(0, 127, 0, 2);
	sustain = cc5.linlin(0, 127, 0, 1);
	release = cc6.linlin(0, 127, 0, 2);

	depth = cc7.linlin(0, 127, 0.1, 2000);
	offset = cc8.linlin(0, 127, 1, 20000);

	ffreq = cc9.linlin(0, 127, 20, 20000);
	rq = cc10.linlin(0, 127, 0, 1);
	morphing = cc11.linlin(0, 127, -1, 1);
	amp = cc12.linlin(0, 127, 0, 1);

    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	sin = SinOsc.kr(modFreq,0,depth,offset);
    osc= SinOsc.ar(carFreq+sin);
    filter1 = DFM1.ar(osc, ffreq, rq);
    filter2 = BMoog.ar(osc, ffreq, rq, 2, 0.5);
	//var filter1 = LPF.ar(osc, ffreq, rq);
	//var filter2 = HPF.ar(osc, ffreq, rq);
	output = XFade2.ar (filter1, filter2, morphing,);
	output*env*0.5*amp;}
)
(
~synth2={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, depth=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    var sin = Saw.kr(modFreq,depth,offset);
    var osc= Saw.ar(carFreq+sin);
    var filter1 = DFM1.ar(osc, ffreq, rq);
    var filter2 = BMoog.ar(osc, ffreq, rq, 2, 0.5);
	//var filter1 = LPF.ar(osc, ffreq, rq);
	//var filter2 = HPF.ar(osc, ffreq, rq);
	var output = XFade2.ar (filter1, filter2, morphing,);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	output*env*0.5*amp;}
);

(
~synth3={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, depth=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    var sin = Pulse.kr(modFreq,0.5,depth,offset);
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
~synth4={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, depth=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    //var sin = Pulse.kr(modFreq,0.5,depth,offset);
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


