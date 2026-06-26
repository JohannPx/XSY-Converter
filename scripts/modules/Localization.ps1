# Localization.ps1 - Multi-language support (FR, EN, ES, IT)

$Script:CurrentLanguage = "FR"

$Script:Strings = @{
    # ============================================================
    # FRANCAIS
    # ============================================================
    "FR" = @{
        # --- App ---
        AppTitle          = "XSY Converter"
        AppSubtitle       = "Conversion variables Schneider Unity Pro"

        # --- Input ---
        LblInputFile      = "Fichier XSY :"
        BtnBrowseInput    = "Parcourir..."
        LblOutputFolder   = "Dossier de sortie :"
        BtnBrowseOutput   = "Parcourir..."
        LblDefaultFolder  = "Bureau (par defaut)"

        # --- Export Format ---
        LblExportFormat   = "Format d'export :"
        OptCsvExchange    = "Table d'echange CSV"
        OptVarLstEwon     = "var_lst (Ewon)"
        OptPcVue          = "PcVue Architect (.csv)"

        # --- PLC Config ---
        LblPlcConfig      = "Configuration automate"
        LblPlcName        = "Nom automate :"
        LblPlcIp          = "Adresse IP :"
        LblPlcUnitId      = "Unit ID :"

        # --- Ewon Config ---
        LblEwonConfig     = "Configuration Ewon"
        LblEwonRepere     = "Prefixe tag (opt.) :"
        LblEwonTopic      = "Topic :"
        LblEwonPage       = "Page :"

        # --- Actions ---
        BtnExport         = "Exporter"

        # --- CSV Columns ---
        ColTag            = "Tag"
        ColZone           = "Zone"
        ColRegistre       = "Registre"
        ColType           = "Type"
        ColDescription    = "Description"
        ColUnite          = "Unite"
        ColRepere         = "Repere"
        ColCoef           = "Coef"
        ColNomAutomate    = "Nom automate"
        ColAdresseIp      = "Adresse IP"
        ColUnitId         = "Unit ID"

        # --- PcVue Columns ---
        ColNom            = "Nom"
        ColAdresseMW      = "Adresse MW"
        ColAdresseX       = "Adresse X"
        ColDecalage       = "Decalage"
        ColWBIT           = "WBIT"
        ColTrame          = "Trame"

        # --- Messages ---
        MsgError          = "Erreur"
        MsgInfo           = "Information"
        MsgNoFile         = "Veuillez selectionner un fichier XSY."
        MsgParseSuccess   = "{0} variable(s) trouvee(s) dans le projet '{1}'"
        MsgParseErrors    = "{0} avertissement(s)"
        MsgEboolExcluded  = "{0} EBOOL (%M) exclu(s) de l'export"
        MsgByteExcluded   = "{0} BYTE exclu(s) de l'export"
        MsgExportDone     = "Export termine !"
        MsgExportSuccess  = "Reussis : {0}"
        MsgExportErrors   = "Erreurs : {0}"
        MsgExportFolder   = "Dossier : {0}"
        MsgExportDetail   = "Details des erreurs :"
        MsgExportCsvDone  = "Export CSV termine !"
        MsgExportEwonDone = "Export var_lst termine !"
        MsgExportPcVueDone = "Export PcVue termine !"
        MsgInvalidXsy     = "Fichier XSY invalide : element racine VariablesExchangeFile manquant."
        MsgNoVariables    = "Aucune variable exploitable trouvee dans le fichier XSY."
        MsgConfirmClose   = "Un export est en cours. Voulez-vous vraiment fermer ?"
        MsgFileCount      = "{0} fichier(s) genere(s)"

        # --- Language ---
        LangLabel         = "Langue :"
    }

    # ============================================================
    # ENGLISH
    # ============================================================
    "EN" = @{
        AppTitle          = "XSY Converter"
        AppSubtitle       = "Schneider Unity Pro Variable Export"
        LblInputFile      = "XSY File:"
        BtnBrowseInput    = "Browse..."
        LblOutputFolder   = "Output folder:"
        BtnBrowseOutput   = "Browse..."
        LblDefaultFolder  = "Desktop (default)"
        LblExportFormat   = "Export format:"
        OptCsvExchange    = "CSV Exchange Table"
        OptVarLstEwon     = "var_lst (Ewon)"
        OptPcVue          = "PcVue Architect (.csv)"
        LblPlcConfig      = "PLC Configuration"
        LblPlcName        = "PLC name:"
        LblPlcIp          = "IP address:"
        LblPlcUnitId      = "Unit ID:"
        LblEwonConfig     = "Ewon Configuration"
        LblEwonRepere     = "Tag prefix (opt.):"
        LblEwonTopic      = "Topic:"
        LblEwonPage       = "Page:"
        BtnExport         = "Export"
        ColTag            = "Tag"
        ColZone           = "Zone"
        ColRegistre       = "Register"
        ColType           = "Type"
        ColDescription    = "Description"
        ColUnite          = "Unit"
        ColRepere         = "Reference"
        ColCoef           = "Coef"
        ColNomAutomate    = "PLC name"
        ColAdresseIp      = "IP address"
        ColUnitId         = "Unit ID"
        ColNom            = "Name"
        ColAdresseMW      = "MW Address"
        ColAdresseX       = "X Address"
        ColDecalage       = "Offset"
        ColWBIT           = "WBIT"
        ColTrame          = "Frame"
        MsgError          = "Error"
        MsgInfo           = "Information"
        MsgNoFile         = "Please select an XSY file."
        MsgParseSuccess   = "{0} variable(s) found in project '{1}'"
        MsgParseErrors    = "{0} warning(s)"
        MsgEboolExcluded  = "{0} EBOOL (%M) excluded from export"
        MsgByteExcluded   = "{0} BYTE excluded from export"
        MsgExportDone     = "Export complete!"
        MsgExportSuccess  = "Succeeded: {0}"
        MsgExportErrors   = "Errors: {0}"
        MsgExportFolder   = "Folder: {0}"
        MsgExportDetail   = "Error details:"
        MsgExportCsvDone  = "CSV export complete!"
        MsgExportEwonDone = "var_lst export complete!"
        MsgExportPcVueDone = "PcVue export complete!"
        MsgInvalidXsy     = "Invalid XSY file: missing VariablesExchangeFile root element."
        MsgNoVariables    = "No usable variables found in the XSY file."
        MsgConfirmClose   = "An export is in progress. Do you really want to close?"
        MsgFileCount      = "{0} file(s) generated"
        LangLabel         = "Language:"
    }

    # ============================================================
    # ESPANOL
    # ============================================================
    "ES" = @{
        AppTitle          = "XSY Converter"
        AppSubtitle       = "Exportar variables Schneider Unity Pro"
        LblInputFile      = "Archivo XSY:"
        BtnBrowseInput    = "Examinar..."
        LblOutputFolder   = "Carpeta de salida:"
        BtnBrowseOutput   = "Examinar..."
        LblDefaultFolder  = "Escritorio (por defecto)"
        LblExportFormat   = "Formato de exportacion:"
        OptCsvExchange    = "Tabla de intercambio CSV"
        OptVarLstEwon     = "var_lst (Ewon)"
        OptPcVue          = "PcVue Architect (.csv)"
        LblPlcConfig      = "Configuracion del PLC"
        LblPlcName        = "Nombre del PLC:"
        LblPlcIp          = "Direccion IP:"
        LblPlcUnitId      = "Unit ID:"
        LblEwonConfig     = "Configuracion Ewon"
        LblEwonRepere     = "Prefijo tag (opc.):"
        LblEwonTopic      = "Topic:"
        LblEwonPage       = "Pagina:"
        BtnExport         = "Exportar"
        ColTag            = "Tag"
        ColZone           = "Zona"
        ColRegistre       = "Registro"
        ColType           = "Tipo"
        ColDescription    = "Descripcion"
        ColUnite          = "Unidad"
        ColRepere         = "Referencia"
        ColCoef           = "Coef"
        ColNomAutomate    = "Nombre del PLC"
        ColAdresseIp      = "Direccion IP"
        ColUnitId         = "Unit ID"
        ColNom            = "Nombre"
        ColAdresseMW      = "Direccion MW"
        ColAdresseX       = "Direccion X"
        ColDecalage       = "Desplazamiento"
        ColWBIT           = "WBIT"
        ColTrame          = "Trama"
        MsgError          = "Error"
        MsgInfo           = "Informacion"
        MsgNoFile         = "Por favor seleccione un archivo XSY."
        MsgParseSuccess   = "{0} variable(s) encontrada(s) en el proyecto '{1}'"
        MsgParseErrors    = "{0} advertencia(s)"
        MsgEboolExcluded  = "{0} EBOOL (%M) excluido(s) de la exportacion"
        MsgByteExcluded   = "{0} BYTE excluido(s) de la exportacion"
        MsgExportDone     = "Exportacion completada!"
        MsgExportSuccess  = "Exitosos: {0}"
        MsgExportErrors   = "Errores: {0}"
        MsgExportFolder   = "Carpeta: {0}"
        MsgExportDetail   = "Detalles de errores:"
        MsgExportCsvDone  = "Exportacion CSV completada!"
        MsgExportEwonDone = "Exportacion var_lst completada!"
        MsgExportPcVueDone = "Exportacion PcVue completada!"
        MsgInvalidXsy     = "Archivo XSY invalido: falta el elemento raiz VariablesExchangeFile."
        MsgNoVariables    = "No se encontraron variables utilizables en el archivo XSY."
        MsgConfirmClose   = "Una exportacion esta en curso. Desea cerrar?"
        MsgFileCount      = "{0} archivo(s) generado(s)"
        LangLabel         = "Idioma:"
    }

    # ============================================================
    # ITALIANO
    # ============================================================
    "IT" = @{
        AppTitle          = "XSY Converter"
        AppSubtitle       = "Esportazione variabili Schneider Unity Pro"
        LblInputFile      = "File XSY:"
        BtnBrowseInput    = "Sfoglia..."
        LblOutputFolder   = "Cartella di uscita:"
        BtnBrowseOutput   = "Sfoglia..."
        LblDefaultFolder  = "Desktop (predefinito)"
        LblExportFormat   = "Formato di esportazione:"
        OptCsvExchange    = "Tabella di scambio CSV"
        OptVarLstEwon     = "var_lst (Ewon)"
        OptPcVue          = "PcVue Architect (.csv)"
        LblPlcConfig      = "Configurazione PLC"
        LblPlcName        = "Nome PLC:"
        LblPlcIp          = "Indirizzo IP:"
        LblPlcUnitId      = "Unit ID:"
        LblEwonConfig     = "Configurazione Ewon"
        LblEwonRepere     = "Prefisso tag (opz.):"
        LblEwonTopic      = "Topic:"
        LblEwonPage       = "Pagina:"
        BtnExport         = "Esporta"
        ColTag            = "Tag"
        ColZone           = "Zona"
        ColRegistre       = "Registro"
        ColType           = "Tipo"
        ColDescription    = "Descrizione"
        ColUnite          = "Unita"
        ColRepere         = "Riferimento"
        ColCoef           = "Coef"
        ColNomAutomate    = "Nome PLC"
        ColAdresseIp      = "Indirizzo IP"
        ColUnitId         = "Unit ID"
        ColNom            = "Nome"
        ColAdresseMW      = "Indirizzo MW"
        ColAdresseX       = "Indirizzo X"
        ColDecalage       = "Offset"
        ColWBIT           = "WBIT"
        ColTrame          = "Trama"
        MsgError          = "Errore"
        MsgInfo           = "Informazione"
        MsgNoFile         = "Selezionare un file XSY."
        MsgParseSuccess   = "{0} variabile(i) trovata(e) nel progetto '{1}'"
        MsgParseErrors    = "{0} avviso(i)"
        MsgEboolExcluded  = "{0} EBOOL (%M) esclusi dall'esportazione"
        MsgByteExcluded   = "{0} BYTE esclusi dall'esportazione"
        MsgExportDone     = "Esportazione completata!"
        MsgExportSuccess  = "Riusciti: {0}"
        MsgExportErrors   = "Errori: {0}"
        MsgExportFolder   = "Cartella: {0}"
        MsgExportDetail   = "Dettagli errori:"
        MsgExportCsvDone  = "Esportazione CSV completata!"
        MsgExportEwonDone = "Esportazione var_lst completata!"
        MsgExportPcVueDone = "Esportazione PcVue completata!"
        MsgInvalidXsy     = "File XSY non valido: elemento radice VariablesExchangeFile mancante."
        MsgNoVariables    = "Nessuna variabile utilizzabile trovata nel file XSY."
        MsgConfirmClose   = "Un'esportazione e in corso. Vuoi davvero chiudere?"
        MsgFileCount      = "{0} file generato(i)"
        LangLabel         = "Lingua:"
    }
}

function T([string]$Key) {
    $s = $Script:Strings[$Script:CurrentLanguage]
    if ($s -and $s.ContainsKey($Key)) { return $s[$Key] }
    # Fallback to French
    $fr = $Script:Strings["FR"]
    if ($fr -and $fr.ContainsKey($Key)) { return $fr[$Key] }
    return "[$Key]"
}

function Set-Language([string]$Lang) {
    if ($Script:Strings.ContainsKey($Lang)) {
        $Script:CurrentLanguage = $Lang
        Set-AppStateValue -Key "Language" -Value $Lang
    }
}

function Get-Language { return $Script:CurrentLanguage }
