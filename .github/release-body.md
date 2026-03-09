# XSY Converter {{VERSION}}

**Date de release** : {{DATE}}
**Commit** : `{{COMMIT_SHA}}`

---

## A propos de cette version

Outil PowerShell + WPF pour convertir les fichiers XSY (export variables Schneider Unity Pro) en formats CSV exploitables : table d'echange, var_lst Ewon (Modbus TCP), PcVue Architect.
Interface multilingue (FR/EN/ES/IT), expansion automatique des DDT et ARRAY.

### Dernier changement
```
{{COMMIT_MSG}}
```

---

## Telecharger

> **Fichier unique auto-contenu** : tous les modules sont integres dans le script lors du build.
> Aucune dependance externe, PowerShell 5.1 natif Windows suffit.

### Ou trouver le fichier ?

Le fichier **`XSY-Converter_latest.ps1`** se trouve dans la section **Assets** tout en bas de cette page (cliquez sur **Assets** pour deplier si necessaire).

### Lancement

1. **Telecharger** le fichier `XSY-Converter_latest.ps1` depuis les **Assets** ci-dessous
2. **Ouvrir PowerShell** : clic-droit sur le menu Demarrer → **Terminal** (ou **Windows PowerShell**)
3. **Lancer** le script :

```powershell
powershell -Sta -ExecutionPolicy Bypass -File "$HOME\Downloads\XSY-Converter_latest.ps1"
```

> `$HOME\Downloads` correspond au dossier Telechargements. Si le fichier est ailleurs, adaptez le chemin.

### Avertissement de securite Windows

Au premier lancement, Windows peut afficher un avertissement car le script provient d'Internet.
Tapez `O` puis Entree pour executer. Pour ne plus voir cet avertissement : clic-droit sur le fichier → Proprietes → cochez Debloquer → OK.

---

## Fonctionnalites

### Formats d'export
- **Table d'echange CSV** : separateur `;`, UTF-8 BOM, en-tete automate (Nom/IP/UnitID), colonnes Tag/Registre/Type/Description/Unite/Repere/Coef
- **var_lst Ewon** : 62 colonnes Latin-1, adresses Modbus TCP (+400001+reg+suffix, unitId, IP), config prefixe/topic/page
- **PcVue Architect** : 1 CSV par equipement, colonnes Nom/Adresse MW/Adresse X/Type/Description/Decalage/WBIT/Trame

### Traitement avance
- Expansion automatique des structures DDT (imbriquees recursivement)
- Expansion des ARRAY en elements individuels avec calcul d'offset
- Gestion ExtractBit pour BOOL dans registres WORD/INT
- Filtrage zones memoire (%MW, %M uniquement)

### Interface
- 4 langues (FR/EN/ES/IT)
- Selection fichier XSY et dossier de sortie
- Choix du format d'export (CSV, Ewon ou PcVue)
- Configuration Ewon integree

---

## Prerequis

| Composant | Minimum |
|-----------|---------|
| **Windows** | 10 / 11 |
| **PowerShell** | 5.1 (inclus dans Windows) |

Aucune installation supplementaire requise.

---

## Support

En cas de probleme :
1. Verifiez que vous utilisez la derniere version
2. Consultez la [documentation](../../README.md)
3. Ouvrez une [issue](../../issues) avec une capture d'ecran de l'erreur

---

*Release automatique generee par GitHub Actions*
