import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        // Config. "Inverter Cores": 0 = nao, 1 = sim, 2 = automatico
        var invertSetting = Application.Properties.getValue("InvertColors") as Number;
        var invert = invertSetting == 1;
        if (invertSetting == 2) {
            invert = resolveAutoInvert(Time.now());
        }
        var bgColor = invert ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(Graphics.COLOR_TRANSPARENT, bgColor);
        dc.clear();
    }

}
