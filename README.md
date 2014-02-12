## Despre

Aranjament de tastatură "Romanian - Programmers" pentru Mac OS X. Proiect implementat folosind [Ukelele](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=ukelele) conform [SR 13392:2004](http://www.secarica.ro/std/sr_13392_2004_08_03.pdf).

Implementarea este completă, însă prezintă următoarele deficiențe:

 * Caracterele speciale nu interacționeză corect cu CAPS LOCK.
 * Ambele taste ALT (option) au rolul de AltGr.

## Instalare / Actualizare

```bash
curl --silent https://raw.github.com/SaltwaterC/romanian-programmers-mac/master/install.sh --output "/tmp/rpm-install.sh" && bash "/tmp/rpm-install.sh" && rm -f "/tmp/rpm-install.sh"
```

**Atenție!**

 * la instalare trebuie activat din *System Preferences > Language & Text > Input Sources > Romanian - Programmers*.
 * la actualizare este nevoie de un logout + login pentru ca schimbările să fie vizibile.
