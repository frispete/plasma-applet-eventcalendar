> Based on version 7 of Zren's i18n scripts, adapted for Plasma 6.

Translations are compiled into `contents/locale/` and bundled with the `*.plasmoid` file.
The `Name`/`Description` translations in `metadata.json` are maintained by hand.

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/frispete/plasma-applet-eventcalendar/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.

## Scripts

* `./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.
* `./plasmoidlocaletest de` will run `./build` then `plasmoidviewer` (part of `plasma6-sdk`) in that locale.

## Links

* https://zren.github.io/kde/docs/widget/#translations-i18n
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

## Examples

* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     183 |       |
| da       | 157/183 |   85% |
| de       | 183/183 |  100% |
| el       | 146/183 |   79% |
| es       | 176/183 |   96% |
| fi       | 176/183 |   96% |
| fr       | 155/183 |   84% |
| he       | 174/183 |   95% |
| it       | 176/183 |   96% |
| ja       | 150/183 |   81% |
| ko       | 173/183 |   94% |
| nl       | 176/183 |   96% |
| pl       | 137/183 |   74% |
| pt_BR    | 176/183 |   96% |
| pt_PT    | 176/183 |   96% |
| ru       | 175/183 |   95% |
| sl       | 155/183 |   84% |
| sv       | 142/183 |   77% |
| tr       | 155/183 |   84% |
| uk       | 136/183 |   74% |
| zh_CN    | 138/183 |   75% |
