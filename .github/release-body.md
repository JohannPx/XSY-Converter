# 📦 XSY Converter {{VERSION}}

**Date de release** : {{DATE}}
**Commit** : `{{COMMIT_SHA}}`

---

## 🎯 À propos de cette version

Outil **PowerShell + WPF** pour convertir les fichiers XSY (export variables Schneider Unity Pro) en formats CSV exploitables : table d'échange, var_lst Ewon (Modbus TCP), PcVue Architect.
Interface multilingue (FR/EN/ES/IT), expansion automatique des DDT et ARRAY.

### 📝 Changements de cette version

{{CHANGELOG}}

---

## 📥 Téléchargement et installation

### 🔽 Option recommandée : Exécutable (.exe)

1. **Télécharger** le fichier **`XsyConverter.exe`** depuis les **Assets** ci-dessous
2. **Double-cliquer** pour lancer

Au premier lancement :
- L'application s'installe automatiquement dans votre profil utilisateur (aucun droit administrateur requis)
- Un raccourci est créé sur le **Bureau** et dans le **Menu Démarrer**
- Les lancements suivants se font via le raccourci

**Mises à jour automatiques** : à chaque démarrage, l'application vérifie si une nouvelle version est disponible sur GitHub et se met à jour silencieusement.

> **Avertissements de sécurité au premier téléchargement/lancement :**
>
> 1. **Navigateur** (Chrome/Edge) : *"XsyConverter.exe n'est pas fréquemment téléchargé"*
>    - Chrome : cliquez sur **`^`** (flèche) → **Conserver**
>    - Edge : cliquez sur **`...`** → **Conserver** → **Conserver quand même**
>
> 2. **Windows SmartScreen** : *"Windows a protégé votre ordinateur"*
>    - Cliquez sur **Plus d'infos** → **Exécuter quand même**
>
> Ces avertissements sont normaux pour un exécutable non signé et n'apparaissent qu'au premier téléchargement.

### 🔽 Option avancée : Script PowerShell (.ps1)

Pour les utilisateurs avancés ou les environnements qui bloquent les exécutables non signés :

1. **Télécharger** le fichier `XSY-Converter_latest.ps1` depuis les **Assets** ci-dessous
2. **Ouvrir PowerShell** : clic-droit sur le menu Démarrer → **Terminal** (ou **Windows PowerShell**)
3. **Lancer** :

```powershell
powershell -Sta -ExecutionPolicy Bypass -File "$HOME\Downloads\XSY-Converter_latest.ps1"
```

> 💡 Adaptez le chemin si vous avez déplacé le fichier. Le `.ps1` est auto-contenu (aucun dossier `modules/` requis à côté).

---

## ✨ Fonctionnalités principales

### 🌍 Multilingue (FR/EN/ES/IT)
- ✅ Sélection de la langue via drapeaux
- ✅ Changement instantané de toute l'interface

### 📤 Formats d'export
- ✅ **Table d'échange CSV** (en-tête automate Nom/IP/UnitID)
- ✅ **var_lst** (Ewon Flexy, Modbus TCP)
- ✅ **PcVue Architect** (1 CSV par équipement)

### 🔧 Traitement avancé
- ✅ Expansion automatique des structures DDT (imbriquées récursivement)
- ✅ Expansion des ARRAY en éléments individuels avec calcul d'offset
- ✅ Byte-packing des BOOL Schneider (X0/X8) + gestion ExtractBit
- ✅ Filtrage des zones mémoire (%MW, %M uniquement)

---

## 📋 Configuration requise

| Composant | Minimum |
|-----------|---------|
| **Windows** | 10 / 11 |
| **PowerShell** | 5.1 (inclus) |

Aucune installation supplémentaire requise.

---

## 🐛 Support

En cas de problème :
1. Vérifiez que vous utilisez la dernière version
2. Consultez la [documentation](https://github.com/JohannPx/XSY-Converter#readme)
3. Ouvrez une [issue](https://github.com/JohannPx/XSY-Converter/issues) avec une capture d'écran de l'erreur

---

*Release automatique générée par GitHub Actions*
