import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        var invert = Application.Properties.getValue("InvertColors") as Boolean;
        var bgColor = invert ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(Graphics.COLOR_TRANSPARENT, bgColor);
        dc.clear();
    }

}
