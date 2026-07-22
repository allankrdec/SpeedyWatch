import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Tela de configuracao no proprio relogio (getSettingsView do App) - mesma
// tecnica usada no SpeedyWatchNative: sem isso, o atalho "Personalizar" do
// carrossel de mostradores nao tem o que abrir.
//
// InvertColors tem 3 opcoes (Nao/Sim/Automatico), entao usa o mesmo padrao
// lista+submenu do SpeedyWatchNative. SwapTimeAndDate continua booleana,
// entao fica como ToggleMenuItem direto no menu principal.

class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title => WatchUi.loadResource(Rez.Strings.SettingsTitle) });

        addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.InvertColorsTitle), null, :invertColors, null));
        addItem(new WatchUi.ToggleMenuItem(
            WatchUi.loadResource(Rez.Strings.SwapTimeAndDateTitle),
            null,
            :swapTimeAndDate,
            Application.Properties.getValue("SwapTimeAndDate") as Boolean,
            null
        ));
    }

}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :invertColors) {
            WatchUi.pushView(
                new OptionsMenu(Rez.Strings.InvertColorsTitle, "InvertColors", [
                    { :value => 0, :label => Rez.Strings.InvertColorsNo },
                    { :value => 1, :label => Rez.Strings.InvertColorsYes },
                    { :value => 2, :label => Rez.Strings.InvertColorsAuto }
                ]),
                new OptionsMenuDelegate("InvertColors"),
                WatchUi.SLIDE_IMMEDIATE
            );
        } else if (id == :swapTimeAndDate) {
            var toggle = item as WatchUi.ToggleMenuItem;
            Application.Properties.setValue("SwapTimeAndDate", toggle.isEnabled());
            WatchUi.requestUpdate();
        }
    }

}

// Segundo nivel: lista as opcoes de uma unica configuracao, com um "✓" na
// que estiver selecionada no momento.
class OptionsMenu extends WatchUi.Menu2 {

    function initialize(titleRes as ResourceId, propertyKey as String, options as Array<Dictionary>) {
        Menu2.initialize({ :title => WatchUi.loadResource(titleRes) });

        var current = Application.Properties.getValue(propertyKey) as Number;
        for (var i = 0; i < options.size(); i++) {
            var opt = options[i];
            var value = opt.get(:value) as Number;
            var label = WatchUi.loadResource(opt.get(:label) as ResourceId) as String;
            var subLabel = (value == current) ? "✓" : null;
            addItem(new WatchUi.MenuItem(label, subLabel, value, null));
        }
    }

}

class OptionsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var propertyKey as String;

    function initialize(propertyKey as String) {
        Menu2InputDelegate.initialize();
        self.propertyKey = propertyKey;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        Application.Properties.setValue(propertyKey, item.getId());
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}
