import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

const WEEKDAY_ABBR as Array<String> = ["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SAB"];
const MONTH_ABBR as Array<String> = [
    "JAN", "FEV", "MAR", "ABR", "MAI", "JUN",
    "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"
];

class SpeedyWatchView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {

        // Hora (respeita config. 12h/24h do relogio)
        var clockTime = System.getClockTime();
        var is24Hour = System.getDeviceSettings().is24Hour;
        var hour = clockTime.hour;
        var amPmStr = "";

        if (!is24Hour) {
            amPmStr = (hour >= 12) ? "PM" : "AM";
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        var timeString = Lang.format(
            "$1$:$2$",
            [hour, clockTime.min.format("%02d")]
        );

        var time = View.findDrawableById("TimeLabel") as Text;
        time.setText(timeString);

        var amPm = View.findDrawableById("AmPmLabel") as Text;
        amPm.setVisible(!is24Hour);
        amPm.setText(amPmStr);

        // Frequência cardíaca
        var heartRateStr = "--";
        var hrSample = ActivityMonitor.getHeartRateHistory(1, true).next();
        if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            heartRateStr = hrSample.heartRate.toString();
        }
        var heart = View.findDrawableById("HeartLabel") as Text;
        heart.setText(heartRateStr);

        // Bateria
        var batteryStr = Lang.format("$1$%", [System.getSystemStats().battery.format("%d")]);
        var battery = View.findDrawableById("BatteryLabel") as Text;
        battery.setText(batteryStr);

        // Dia da semana e data
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        var weekday = View.findDrawableById("WeekdayLabel") as Text;
        weekday.setText(WEEKDAY_ABBR[today.day_of_week - 1]);

        var dateStr = Lang.format("$1$ $2$", [today.day, MONTH_ABBR[today.month - 1]]);
        var date = View.findDrawableById("DateLabel") as Text;
        date.setText(dateStr);

        View.onUpdate(dc);

        // Linhas divisorias (teste): separam hora / FC+bateria / dia+data
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(24, 60, 152, 60);
        dc.drawLine(24, 114, 152, 114);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
