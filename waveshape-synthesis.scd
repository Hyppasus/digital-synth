(
SynthDef(\waveshaper,
	{
		arg freq = 140, amp = 0.4, srcAmp = 0.3, att = 0.01, rel = 1.5;
		var src, shaped, out, playHead, env;

		env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		src = SinOsc.ar(freq, 0, srcAmp);
    playHead = LinLin.ar(src, -1.0,1.0, 0, BufFrames.kr(0)).wrap(0, BufFrames.kr(0));
    shaped = BufRd.ar(1, 0, playHead);
    out = shaped*env;
    out = out*amp;
    Out.ar(0, out!2);
  };
  ).add;
)

(Pdef(\lspat,
	Pbind(
		\instrument, \lsShaper,
		\freq, Prand([150, 195, 175, 220, 200, 230, 270, 300, 25, 50, 40, 60, 75], inf)*2,
		\srcAmp, Pwhite(0.1, 0.4, inf),
		\att, Pwhite(0, 2.5, inf),
		\rel, Pwhite(3, 4.5, inf),
		\amp, Pwhite(0.4, 0.8, inf),
		\dur, Prand([0.5, 0.25, 0.75], inf),
	)
).play)
