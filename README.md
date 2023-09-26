# NodeHarjoituksia
Web-palvelinten toimintaan liittyviä esimerkkejä toteutettuna Node.js kirjastoon avulla

## Tietoka8nta ja näkymät

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
