# NodeHarjoituksia
Web-palvelinten toimintaan liittyviä esimerkkejä toteutettuna Node.js kirjastoon avulla

## Tietokanta ja näkymät

Luodaan näkymä, joka laskee edellisen kuukauden hinnan keskiarvon, normaalihinnan ala ja ylärajat keskihajonnan perusteella. Jaetaan vaatimukset tehtäviksi tyyliin:

1. Selvitä kuluva vuosi ja kuukausi
2. Laske, mikä on edellisen kuukauden numero
3. Tee kysely, joka laskee tarvittavat keskiarvot ja keskihajonnat
4. Määrittele rajoittava ehto kuukaudelle ja vuodelle (tämän vuoden edell. kuukausi)
5. Muokka kyselyä sitten, että se laskee ala-ja ylärajat (keskihinta +/- keskihajonta)
6. Muuta näkymäksi, joka hyödyntää month_lookup-taulua.

Luodaan käkymä, joka näyttää tiedot edelliseltä vuodelta, mutta kuluvalta kuukaudelta

## Mikropalvelu datan hakemiseen ja tallentamiseen

![Microservice](https://github.com/HasanbasriUysal/NodeHarjoituksia/assets/122529625/5b4ae51a-7f61-45ff-bfa8-ee8ee6864f98)

Node.js palvelin voi tehdä ajastettuja toimintoja. Selvitä, mitä kirjastoja voisi käyttää tähän tarkoitukseen. Luodaan palvelu, joka lukee päivittäin klo 15.30 hinnat ja tallentaa ne tietokantaan. Jos ei onistu, yritetään uudelleen tunnin kuluttua.

### Node.js ajastin (scheduler)
Jakakaa projektiryhmässä työt: kuka katsoo mitäkin työkalua tai kirjastoa. Lisätkää ne kortteina Githubin projektinhallintaan. Laittakaa tutkimiinne kirjastoihin kommentteina mielipide: "jatkoon, ei jatkoon" ja lyhyt perustelu miksi.

### PostgreSQL-kirjasto
Selvittäkää, mitä työkaluja / kirjastoja voisi käyttää tiedon hakemiseen ja tallentamiseen Node-sovelluksesta PostgreSQL-tietokantaan. Jakakaa tehtävät ja kirjatkaa projektinhallintaan. Mielipiteet kuten edellisessä tehtävässä.
Tehtävä: Rakenna palvelu valmiiksi niin, että se pystyy hakemaan päivittäin hintatiedot porssisahko.net-palvelusta ja tallentamaan ne tietokantaan. Esimerkkikoodissa haku- ja tallennustapahtumat kaiutetaan konsoliin. Todellisessa palvelimessa ne halutaan kirjoittaa lokitiedostoon. Lisää koodiin kirjoitus tiedostoon (append) fs-kirjaston avulla.
# Pikadokumentaatio
Seuraavasta taulukosta löytyvät tämän projektin tärkeimmät tiedostot ja hakemistot:
|Tiedosto tai kansio|	Käyttötarkoitus|
|---|---|
app.js |	web-palvelinohjelmisto sivujen tuottamiseen
microservice.js |	mikropalvelu, joka noutaa hintatiedot ja tallentaa ne PosgtreSQL-tietokantaa
getNewPrices.js	| Moduuli, jossa on rutiini hintatietojen hakemiseen porssisahko.net-palvelusta
DBObjectScripts	|Kansiosta löytyvät tietokantapalvelimen varmuuskopiot ja objektien luontiskriptit
Data	| Kansiosta löytyy oikeaan muotoon muunnettua dataa, joka voidaan tuoda tietokantaan
Examples |	Wikisivuilla käytettyjen esimerkkien javascript-koodit
Planning |	Suunnitteluun liittyvät SQL Power Arcitect -käsitemallit
Tietokantaan on luotu joukko näkymiä. Niiden käyttötarkoitukset ilmenevät seuraavasta taulukosta:

|Nimi| Käyttötarkoitus|
|---|---|
current_prices|	Sähkön pörssihinnat tästä hetkestä eteenpäin
running_average|	Sähkön hinnan keskiarvo koko aineistosta
running_average_stdev|	Sähkön hinnan keskiarvo ja keskihajonta koko aineistosta
average_by_year_and_month|	Sähkön kuukausittaiset keskihinnat ja hajonta eri vuosilta
previous_month_average|	Edellisen kuukauden sähkön keskihinta ja keskihajonnan mukaiset rajat
avg_price_by_weekday_num|	Keskihinnat viikonpäivittäin viikonpäivänumeroin
avg_price_by_weekday_name|	Keskihinnat viikonpäivittäin viikonpäivän nimin (fi, se, uk, de, tr)
average_by_year|	Vuosittainen keskihinta
average_year-month_day|	Päivän keskihinnat koko aineistosta
monthly_averages_by_year_fin|	Keskihinnat kuukausittain ja vuosittain, kuukausien nimet suomeksi
