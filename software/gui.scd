
(
Window.closeAll;

w = Window.new.front;


~houseLabel = StaticText(w, Rect(20, 20, 40, 40));
~houseLabel.string = "House Gain";
~houseLabel.align =  \center;
~houseGain = NumberBox(w, Rect(20, 60, 40, 20));
~houseGainSlider = Slider(w, Rect(30, 90, 20, 150)).action_({
	~houseGain.value_(~houseGainSlider.value);
	y.set(\bus1amp, ~houseGainSlider.value);
        });
//~houseGainSlider.action.value;
~houseGainSlider.valueAction = 1.0; // initialize

~ensLabel = StaticText(w, Rect(80, 20, 60, 40));
~ensLabel.string = "Ensemble Gain";
~ensLabel.align = \center;
~ensGain = NumberBox(w, Rect(90, 60, 40, 20));
~ensGainSlider = Slider(w, Rect(100, 90, 20, 150)).action_({
	~ensGain.value_(~ensGainSlider.value);
	z.set(\amp, ~ensGainSlider.value); // just map this to the right synth. maybe some smoothing?
});
~ensGainSlider.action.value;
~ensGainSlider.valueAction = 1.0; // initialize

)

