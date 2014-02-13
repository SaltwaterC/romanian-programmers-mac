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

 * la instalare trebuie activat din:
  * *System Preferences > Language & Text > Input Sources > Romanian - Programmers* (OS X 10.8).
  * *System Preferences > Keyboard > Input Sources > [+] > Others > Romanian - Programmers* (OS X 10.9).
 * la actualizare este nevoie de un logout + login pentru ca schimbările să fie vizibile.
 * scriptul de instalare invocă sudo pentru a putea executa acțiunie dorite. Dacă securitatea este o problemă, este recomandată clonarea acestui depozit, urmată de o instalare manuală, sau de o instalare locală (`./install.sh local`) după ce scriptul de instalare este inspectat.
