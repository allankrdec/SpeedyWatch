import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

const WEEKDAY_ABBR_PT as Array<String> = ["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SAB"];
const MONTH_ABBR_PT as Array<String> = [
    "JAN", "FEV", "MAR", "ABR", "MAI", "JUN",
    "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"
];

const WEEKDAY_ABBR_EN as Array<String> = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
const MONTH_ABBR_EN as Array<String> = [
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
];

class SpeedyWatchView extends WatchUi.WatchFace {

    private var isSleeping as Boolean = false;

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

        // Cores (config. "Inverter Cores")
        var invert = Application.Properties.getValue("InvertColors") as Boolean;
        var fgColor = invert ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;

        // Posicao da hora e do dia/data (config. "Trocar Hora/Data").
        // A linha do meio (coracao/bateria) nunca muda de lugar, porque e
        // onde os ponteiros passam.
        var swapTimeAndDate = Application.Properties.getValue("SwapTimeAndDate") as Boolean;
        var timeY = swapTimeAndDate ? 128 : 11;
        var weekdayDateY = swapTimeAndDate ? 30 : 140;

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

        var minute = clockTime.min;
        var screenWidth = dc.getWidth();

        var timeTokens = bigTimeTokens(hour, minute);
        var timeWidth = bigTimeWidth(timeTokens);
        var timeEndX = (screenWidth + timeWidth) / 2;

        // Nao deixa o AM/PM passar da borda direita, mesmo com hora de 2
        // digitos (ex: "12:33 PM")
        var amPmX = timeEndX + 4;
        var amPmMaxX = screenWidth - 20;
        if (amPmX > amPmMaxX) {
            amPmX = amPmMaxX;
        }

        var amPm = View.findDrawableById("AmPmLabel") as Text;
        amPm.setLocation(amPmX, timeY + 24);
        amPm.setColor(fgColor);
        amPm.setVisible(!is24Hour);
        amPm.setText(amPmStr);

        // Frequência cardíaca
        var heartRateStr = "--";
        var hrSample = ActivityMonitor.getHeartRateHistory(1, true).next();
        if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            heartRateStr = hrSample.heartRate.toString();
        }
        var heartIcon = View.findDrawableById("HeartIcon") as Bitmap;
        heartIcon.setBitmap(invert ? Rez.Drawables.HeartIconBlack : Rez.Drawables.HeartIconWhite);

        var heart = View.findDrawableById("HeartLabel") as Text;
        heart.setColor(fgColor);
        heart.setText(heartRateStr);

        // Bateria
        var batteryStr = Lang.format("$1$%", [System.getSystemStats().battery.format("%d")]);
        var batteryIcon = View.findDrawableById("BatteryIcon") as Bitmap;
        batteryIcon.setBitmap(invert ? Rez.Drawables.BatteryIconBlack : Rez.Drawables.BatteryIconWhite);

        var battery = View.findDrawableById("BatteryLabel") as Text;
        battery.setColor(fgColor);
        battery.setText(batteryStr);

        // Dia da semana e data (PT se o relogio estiver em portugues, EN nos demais casos)
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var isPortuguese = System.getDeviceSettings().systemLanguage == System.LANGUAGE_POR;
        var weekdayAbbr = isPortuguese ? WEEKDAY_ABBR_PT : WEEKDAY_ABBR_EN;
        var monthAbbr = isPortuguese ? MONTH_ABBR_PT : MONTH_ABBR_EN;

        var weekday = View.findDrawableById("WeekdayLabel") as Text;
        weekday.setLocation(38, weekdayDateY);
        weekday.setColor(fgColor);
        weekday.setText(weekdayAbbr[today.day_of_week - 1]);

        var dateStr = Lang.format("$1$ $2$", [today.day, monthAbbr[today.month - 1]]);
        var date = View.findDrawableById("DateLabel") as Text;
        date.setLocation(128, weekdayDateY);
        date.setColor(fgColor);
        date.setText(dateStr);

        View.onUpdate(dc);

        // Hora em digitos grandes (matriz de pontos 5x7), desenhada depois do
        // View.onUpdate porque o Background limpa a tela antes disso
        drawBigTime(dc, hour, minute, timeY, screenWidth, fgColor);

        // Linhas divisorias: escondidas no modo de baixo consumo (sleep/AOD)
        // pra acender menos pixels na tela e economizar bateria
        if (!isSleeping) {
            dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(18, 60, 158, 60);
            dc.drawLine(18, 114, 158, 114);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isSleeping = false;
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        // Forcado em false por enquanto: nao queremos esconder as linhas
        // divisorias so por a tela estar em modo de baixo consumo (o
        // "sleep" aqui e so a tela, nao tem nada a ver com o usuario
        // dormindo). Deixar pronto pra reativar se um dia fizermos algo
        // tipo modo "nao perturbe" de verdade.
        isSleeping = false;
        WatchUi.requestUpdate();
    }

}
