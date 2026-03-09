# XSY Converter

![PowerShell 5.1](https://img.shields.io/badge/PowerShell-5.1-blue)
![WPF](https://img.shields.io/badge/UI-WPF-purple)
![License MIT](https://img.shields.io/badge/License-MIT-green)
[![GitHub Release](https://img.shields.io/github/v/release/jpr-codit/XSY-Converter?label=Release)](https://github.com/jpr-codit/XSY-Converter/releases/latest)

Outil PowerShell/WPF pour convertir les fichiers **XSY** (export variables Schneider Unity Pro) en plusieurs formats CSV exploitables.

## Fonctionnalites

- **Parsing XSY complet** : lecture du format XML Schneider Unity Pro (VariablesExchangeFile)
- **3 formats d'export** :
  - Table d'echange CSV (separateur `;`, UTF-8 BOM)
  - var_lst Ewon Flexy (62 colonnes, Modbus TCP, Latin-1)
  - PcVue Architect (1 CSV par equipement, UTF-8 BOM)
- **Expansion automatique des DDT** : structures imbriquees resolues recursivement
- **Expansion des ARRAY** : `ARRAY[0..23] OF REAL` deploye en 24 variables individuelles avec calcul d'offset
- **Gestion ExtractBit** : BOOL extraits des registres WORD/INT avec position bit
- **Filtrage intelligent** : seules les zones %MW et %M sont conservees (%SW, %S ignores)
- **Interface graphique WPF** : selection fichier, choix du format, configuration Ewon
- **4 langues** : FR / EN / ES / IT (drapeaux interactifs)
- **Distribution en fichier unique** : un seul `.ps1` auto-contenu (release GitHub)

## Prerequis

| Composant | Version |
|-----------|---------|
| Windows | 10 / 11 |
| PowerShell | 5.1 (inclus dans Windows) |
| .NET Framework | 4.5+ (inclus dans Windows) |

Aucune installation supplementaire requise.

## Installation

### Option 1 : Release (recommande)

Telecharger `XSY-Converter_latest.ps1` depuis la [derniere release](https://github.com/jpr-codit/XSY-Converter/releases/latest).

### Option 2 : Sources

```bash
git clone https://github.com/jpr-codit/XSY-Converter.git
```

## Utilisation

### Lancement

**Depuis la release :**
```powershell
powershell -Sta -ExecutionPolicy Bypass -File "$HOME\Downloads\XSY-Converter_latest.ps1"
```

**Depuis les sources :**
```powershell
powershell -Sta -ExecutionPolicy Bypass -File "scripts\XSY-Converter.ps1"
```

### Workflow

1. Cliquer **Parcourir** pour selectionner un fichier `.xsy`
2. Choisir le dossier de sortie (Bureau par defaut)
3. Choisir le format d'export (CSV, Ewon ou PcVue)
4. Si **var_lst Ewon** est selectionne, configurer le prefixe tag, le topic (A/B/C), la page (1-11) et l'adresse IP de l'automate
5. Cliquer **Exporter**
6. Le dossier de sortie s'ouvre automatiquement

### Formats de sortie

#### Table d'echange CSV

Fichier CSV avec separateur `;` et encodage UTF-8 BOM.

En-tete : Nom automate, Adresse IP, Unit ID (3 lignes).

| Colonne | Description |
|---------|-------------|
| Tag | Nom de la variable |
| Registre | Adresse registre (ex: 3700 ou 3706.0) |
| Type | Type de donnee (BOOL, INT, REAL, etc.) |
| Description | Commentaire de la variable |
| Unite | Unite de mesure (vide, non dispo dans XSY) |
| Repere | Repere (vide, non dispo dans XSY) |
| Coef | Coefficient (vide, non dispo dans XSY) |

#### var_lst Ewon

Fichier `var_lst.csv` compatible Ewon Flexy, encodage Latin-1 (ISO-8859-1), 62 colonnes.

- **ServerName** : `MODBUS` (Modbus TCP)
- **Address** : `+{400001+reg}{suffix}{bit},{unitId},{IP}` (ex: `+400100F`, `+400051#0`)
- Suffixes : `#`=BOOL, `I`=INT, `W`=UINT, `F`=REAL/LREAL, `L`=DINT, `D`=UDINT
- Types Ewon : 0=BOOL, 1=Float, 2=Int, 3=DWord

#### PcVue Architect

Sous-dossier horodate avec 1 fichier CSV par equipement/groupe de variables.

| Colonne | Description |
|---------|-------------|
| Nom | Nom complet de la variable |
| Adresse MW | Numero de registre %MW |
| Adresse X | Adresse bit pour BOOL (X0, X1...) |
| Type | Type Unity Pro original |
| Description | Commentaire |
| Decalage | Offset relatif au debut du groupe |
| WBIT | Position bit pour BOOL |
| Trame | Reference frame (ex: MW4200) |

### Expansion DDT / Array

**DDT (structures)** : les types derives (DDT_xxx) sont automatiquement deployes en variables individuelles avec calcul des offsets de registre.

Exemple : `DDT_RESEAU_FROID_ETAT` a l'adresse `%MW1800` avec un membre `r_PRESSION` de type REAL en position +2 donnera :
```
DDT_RESEAU_FROID_ETAT.r_PRESSION  →  %MW1802  (REAL)
```

**ARRAY** : les tableaux sont deployes element par element.

Exemple : `TAB_MESURES` de type `ARRAY[0..3] OF REAL` a l'adresse `%MW100` :
```
TAB_MESURES[0]  →  %MW100  (REAL, 2 registres)
TAB_MESURES[1]  →  %MW102
TAB_MESURES[2]  →  %MW104
TAB_MESURES[3]  →  %MW106
```

## Architecture

```
scripts/
  XSY-Converter.ps1           Point d'entree (STA, modules, GUI)
  modules/
    AppState.ps1               Etat central de l'application
    Localization.ps1            Traductions FR/EN/ES/IT
    XsyParser.ps1               Parsing XML, expansion DDT/Array
    ExportCsv.ps1               Export table d'echange CSV
    ExportEwon.ps1              Export var_lst Ewon (Modbus TCP)
    ExportPcVue.ps1             Export PcVue Architect (multi-CSV)
    UIHelpers.ps1               Composants WPF reutilisables
    UI.ps1                      Interface XAML + logique evenements
```

| Module | Responsabilite |
|--------|---------------|
| AppState | Etat global : fichier source, variables parsees, config export |
| Localization | Dictionnaire FR/EN/ES/IT avec fonction `T()` |
| XsyParser | Parsing XML XSY, construction DDT map, expansion recursive |
| ExportCsv | Generation CSV table d'echange (`;`, UTF-8 BOM) |
| ExportEwon | Generation var_lst 62 colonnes (Latin-1, Modbus TCP) |
| ExportPcVue | Generation multi-CSV PcVue Architect par equipement |
| UIHelpers | Banniere de statut, gestion visibilite |
| UI | Definition XAML WPF + event handlers |

## Format XSY

Le format XSY est un export XML de Schneider Unity Pro (element racine `VariablesExchangeFile`) contenant :
- **`<dataBlock>`** : variables du projet avec nom, type, adresse topologique et commentaires
- **`<DDTSource>`** : definitions de types derives (structures) avec leurs membres

Types supportes : BOOL, EBOOL, INT, UINT, WORD, BYTE, DINT, UDINT, REAL, LREAL, LINT, ULINT, STRING, et les ARRAY de ces types.

## Auteur

**JPR**

## Licence

MIT
