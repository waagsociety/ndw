# Het koppelen van wegvakken aan meetpunten.

## Beschrijving NBW

Dynamic Segmentation is in GIS-systemen een veel gebruikte techniek om voor presentatie- en analysedoeleinden gegevens te koppelen aan wegenbestanden zoals het Nationaal Wegenbestand. Met behulp van  Dynamic Segmentation wordt – bovenop de laag met wegvakken in het NWB – een routenetwerk gecreëerd waarlangs een meetlat te leggen is  waardoor gebruik kan worden gemaakt van relatieve plaatsbepaling t.o.v een beginpunt in plaats van te werken met x- en y-coördinaten. 

Bij Rijkswaterstaat worden veel wegkenmerken opgeslagen in bestanden waarbij als lokatiereferentie wegnummer en de afstand tot de nabijgelegen hectometerpaal wordt gebruikt..
Het NWB-wegen bevat  de positie van hectopalen bij rijkswegen en daardoor is het mogelijk naast het direct koppelen aan wegvakken op basis van coördinaten , ook te koppelen op basis van  hectometrerings gegevens van wegvakken. 
Middels dynamic segmentation  kunnen lijn- en puntgegevens  aan het netwerk worden gekoppeld  met gebruikmaking van ‘kilometer-naar’ en ‘kilometer-van’ , die afgeleid kan worden uit de  positie van de hectometerborden langs de weg. 

Voorbeelden van lijn- en puntgegevens die kunnen worden gekoppeld zijn verkeersintensiteiten, filegegevens, ongevallen, wegkwaliteit, type asfalt, geluidschermen etc. Op deze wijze kan de positie van bijvoorbeeld een ongeval op een bepaald punt langs de weg, stel: kilometerpunt 7.1 op rijksweg 200, gemakkelijk op het wegennetwerk worden gepresenteerd. Ook kan voor verschillende delen van een rijksweg, stel: van kilometerpunt 7.1 tot kilometerpunt 10.9 op rijksweg 200, overzichtelijk de wegkwaliteit of het aantal files worden weergegeven.

Mogelijkheden en beperkingen
Dynamic Segmentation biedt gebruikers van het NWB een aantal mogelijkheden, zoals:
Het kunnen koppelen van gegevens aan geografie op basis van niet geometrische attribuut gegevens.
Een presentatie op basis van relatieve positionering, die parallel loopt aan de fysieke hectometerborden langs rijkswegen. Hiermee is het een overzichtelijke, minder abstracte methode om aan de hand van de werkelijkheid gegevens op een digitaal netwerk te presenteren;
In combinatie met het bovenstaande punt wordt tevens de data-inwinning vereenvoudigd; omdat de geografische ligging in coördinaten niet vereist is.
Bij geografische wijzigingen in het netwerk, zoals vormveranderingen van wegvakken, hoeven de gegevens die met  relatieve plaatsbepaling op basis van hectometrering zijn ingewonnen niet , dit integenstelling tot gegevens ingewonnen aan de hand van coördinaten wel, aangepast te worden. Immers, in het laatste geval dienen de coördinaten van zo’n gegevens opnieuw te worden berekend of opnieuw te worden ingewonnen, omdat bij Dynamic Segmentation de hectometrering ten opzichte van het nulpunt onveranderd blijft waardoor de locatie van het gegeven automatisch mee verandert.

head van wegen databestand:

`````
WVK_ID,WVK_BEGDAT,JTE_ID_BEG,JTE_ID_END,WEGBEHSRT,WEGNUMMER,WEGDEELLTR,HECTO_LTTR,BAANSUBSRT,RPE_CODE,ADMRICHTNG,RIJRICHTNG,STT_NAAM,WPSNAAMNEN,GME_ID,GME_NAAM,HNRSTRLNKS,HNRSTRRHTS,E_HNR_LNKS,E_HNR_RHTS,L_HNR_LNKS,L_HNR_RHTS,BEGAFSTAND,ENDAFSTAND,BEGINKM,EINDKM,POS_TV_WOL
`````

uitleg velden:

`````
FNODE#
JTE_ID_BEGIN (beginjunctie)
ADMRICHTNG
(administratieve richting)
E_HNR_RECHTS (idem voor rechts)
TNODE#
JTE_ID_EIND (eindjunctie)
RIJRICHTNG
(rijrichting)
L_HNR_LINKS (laatste huisnummer links)
LPOLY#
WEGBEHSRT (wegbeheerdersoort)
STT_NAAM
(straatnaam)
L_HNR_RECHTS  (idem voor rechts)
RPOLY#
WEGNUMMER

WPSNAAMNEN (woonplaatsnaam)
BEGAFSTAND
(beginafstand)
LENGTH
WEGDEELLTR
(wegdeelletter)
GME_ID
(cbs gemeentenummer)
ENDAFSTAND
(eindafstand)
WEGVAKKEN#
HECTO_LTTR (hectometreringsklasse)
GME_NAAM (gemeentenaam)
BEGINKM
(beginkilometreing)
WEGVAKKEN-ID
RPE_CODE
(relatieve positie code)
HNSTRLNKS (huisnummerstructuur links)
EINDKM
(eindkilometrering)
WVK_ID (unieke code)
BAANSUBSRT
(baansubsoort code)
HNSTRRCHTS (idem voor rechts)
BAANPOS_TV_WOL (baanpositie t.o.v. wol)
WVK_BEGDAT ( datum opname in BN)
RPE_CODE
(relatieve Positiecode)
E_HNR_LINKS (eerste huisnummer links)
LIJN_LEN
( dit veld wordt niet gevuld)
`````

we hebben dus wegnummer, beginafstand en eindafstand voor ieder wegvak.

## Beschrijving NDW

Het locatie gedeelte van een meetpunt ziet er als volgt uit:


    <measurementSiteLocationxsi:type="Point">
      <locationForDisplay>
        <latitude>51.6587</latitude>
        <longitude>5.1459</longitude>
      </locationForDisplay>
      <alertCPointxsi:type="AlertCMethod4Point">
        <alertCLocationCountryCode>8</alertCLocationCountryCode>
        <alertCLocationTableNumber>5.1</alertCLocationTableNumber>
        <alertCLocationTableVersion>A</alertCLocationTableVersion>
        <alertCDirection>
          <alertCDirectionCoded>positive</alertCDirectionCoded>
        </alertCDirection>
        <alertCMethod4PrimaryPointLocation>
          <alertCLocation>
            <specificLocation>9365</specificLocation>
          </alertCLocation>
          <offsetDistance>
            <offsetDistance>0</offsetDistance>
          </offsetDistance>
        </alertCMethod4PrimaryPointLocation>
      </alertCPoint>
    </measurementSiteLocation>

Als we dan kijken in de VILD database vinden we de volgende attributen:

    LOC_NR,LOC_TYPE,LOC_DES,ROADNUMBER,ROADNAME,FIRST_NAME,SECND_NAME,JUNCT_REF,EXIT_NR,HSTART_POS,HEND_POS,HSTART_NEG,HEND_NEG,HECTO_CHAR,HECTO_DIR,POS_IN,POS_OUT,NEG_IN,NEG_OUT,DIR,AREA_REF,LIN_REF,INTER_REF,POS_OFF,NEG_OFF,URBAN_CODE,PRES_POS,PRES_NEG,FAR_AWAY,CITY_DISTR,TOP_SIGN,TYPE_CODE,MW_REF,RW_NR,AW_REF

Voor bovenstaand voorbeeld is dat:

    9365,P1.2,Knooppunt (triangle),A50,,Paalgraven,A59,9365,,1316,1316,1315,1315,,1,1,0,0,1,,2719,3349,9835,9367,9487,0,1,1,0,,,0,484,50,582


In dit geval is de offset 0, dus het meetpunt ligt precies op dit knooppunt, waarvan we het wegnummer hebben, en hectometerstartpos / endpos, direction etc.

## Koppeling

De koppeling kan worden gemaakt door te kijken of de hectometer locatie van een meetpunt ligt tussen het begin en eind hectopunt van een van de wegvakken met hetzelfde wegnummer.
 
