> Based on version 7 of Zren's i18n scripts, adapted for Plasma 6.

Translations are compiled into `contents/locale/` and bundled with the `*.plasmoid` file.
The `Name`/`Description` translations in `metadata.json` are maintained by hand.

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/Zren/plasma-applet-eventcalendar/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

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
| Template |     219 |       |
| da       | 184/219 |   84% |
| de       | 215/219 |   98% |
| el       | 167/219 |   76% |
| es       | 218/219 |   99% |
| fi       | 215/219 |   98% |
| fr       | 186/219 |   84% |
| he       | 216/219 |   98% |
| it       | 215/219 |   98% |
| ja       | 183/219 |   83% |
| ko       | 215/219 |   98% |
| nl       | 219/219 |  100% |
| pl       | 157/219 |   71% |
| pt_BR    | 215/219 |   98% |
| pt_PT    | 214/219 |   97% |
| ru       | 215/219 |   98% |
| sl       | 193/219 |   88% |
| sv       | 179/219 |   81% |
| tr       | 183/219 |   83% |
| uk       | 157/219 |   71% |
| zh_CN    | 166/219 |   75% |
